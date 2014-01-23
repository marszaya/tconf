package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.text.TextField;
	
	public class TconfParser extends Sprite
	{
		private var _content:Content;
		
		public function TconfParser() {
			// constructor code
			_content = new Content;
			this.fileInput.addEventListener(MouseEvent.CLICK, onFileInput);
			this.protoSave.addEventListener(MouseEvent.CLICK, onProteSave);
			this.xmlSave.addEventListener(MouseEvent.CLICK, onXMLSave);
		}
		
		function onFileInput(event: MouseEvent):void
		{
			//支持的数据格式(编码都要是utf8)
			//1 tab隔开的txt （第一行为字段名称）
			//2 excel导出的xml
			var f:File = new File;
			f.addEventListener(Event.SELECT, onFileOpen);
			f.browseForOpen("选择输入文件",[new FileFilter("xml", "*.xml"), new FileFilter("tab分隔的txt", "*.txt"), new FileFilter("proto2进制数据", "*") ]);
		}
		
		
		function onProteSave(event: MouseEvent):void
		{
			//save to proto 文件
			var f:File = new File;
			f.addEventListener(Event.SELECT, onWriteProto);
			f.browseForSave("选择输出文件");			
		}
		
		function onWriteProto(event:Event):void
		{
			var f:File = event.target as File;
			f.removeEventListener(Event.SELECT, onWriteProto);
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.WRITE);
			
			//data文件		
			_content.createProto(fs);
			fs.close();
			this.txtOutput.appendText("Proto文件<"+f.nativePath+">已保存\n");
			
			//as3 file
			var path:String = f.nativePath.substr(0, f.nativePath.lastIndexOf("\\"))+"\\"+_content.tagName+".as";
			fs.open(new File(path),  FileMode.WRITE);
			fs.writeMultiByte(_content.createAS(),"utf-8");
			fs.close();
			this.txtOutput.appendText(".as <"+path+">已保存\n");
			
			//h file
			path = f.nativePath.substr(0, f.nativePath.lastIndexOf("\\"))+"\\"+_content.tagName+".h";
			fs.open(new File(path), FileMode.WRITE);
			fs.writeMultiByte(_content.createH(),"utf-8");
			fs.close();
			this.txtOutput.appendText(".h <"+path+">已保存\n");
			
			//h file v2
			path = f.nativePath.substr(0, f.nativePath.lastIndexOf("\\"))+"\\"+_content.className+".h";
			fs.open(new File(path), FileMode.WRITE);
			fs.writeMultiByte(_content.createH2(),"utf-8");
			fs.close();
			this.txtOutput.appendText(".h <"+path+">已保存\n");
		}
		
		function onXMLSave(event: MouseEvent):void
		{
			//cocos2d 可导入dict的xml格式
			var f:File = new File;
			f.addEventListener(Event.SELECT, onWriteXML);
			f.browseForSave("选择输出文件");
		}
		
		function onWriteXML(event:Event):void
		{
			var f:File = event.target as File;
			f.removeEventListener(Event.SELECT, onWriteXML);
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.WRITE);
			
			fs.writeMultiByte('<?xml version="1.0" encoding="UTF-8"?>\n','utf-8');
			fs.writeMultiByte('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n','utf-8');
			fs.writeMultiByte(_content.dumpToXML().toXMLString(),"utf-8");
			
			fs.close();
			this.txtOutput.appendText("XML <"+f.nativePath+">已保存\n");
		}
		
		function onFileOpen(event:Event):void
		{
			var f:File = event.target as File;
			f.removeEventListener(Event.SELECT, onFileOpen);
			
			this.txtOutput.text = "开始解析\n";
			//判断输入文件的类型
			var ret:Boolean = false;
			_content.reset();
			
			this.protoSave.enabled = false;
			this.xmlSave.enabled = false;
			
			if(f.extension == "xml")
			{
				this.txtOutput.appendText("文件格式xml\n");
				ret = parseXML(f);
			}
			else if(f.extension == "txt")
			{
				this.txtOutput.appendText("文件格式txt\n");
				ret = parseTxt(f);
			}
			else
			{
				//显示2进制数据内容
				parseBin(f);
				return;
			}
			
			if(!ret)
			{
				this.txtOutput.appendText("解析失败\n");
				return;
			}
			
			this.protoSave.enabled = true;
			this.xmlSave.enabled = true;
			
			this.txtOutput.appendText(_content.summary());
			
		}
		
		function parseXML(f:File):Boolean
		{
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.READ);
			var x:XML = new XML(fs.readMultiByte(fs.bytesAvailable, "utf-8"));
			fs.close();
			fs = null;
			
			var colInited:Boolean = false;
			var rowIdx:int = 0;
			_content.tagName = "Auto"+x.name();
			_content.className = "C"+_content.tagName;
			for each(var row:XML in x.children())
			{
				var rowData:Array = null;
				var colIdx:int = 0;
				for each(var rowCol:XML in row.children())
				{
					if(!colInited)//初始化列名
					{
						if(!_content.addColName(rowCol.name()))
						{
							this.txtOutput.appendText("列名重复："+rowCol.name()+"\n");
							return false;
						}
					}
					else
					{
						if(rowCol.name() != _content.colNameAt(colIdx))
						{
							this.txtOutput.appendText("第"+(rowIdx+1)+"行，第"+(colIdx+1)+"列，列名错误："+rowCol.name()+"\n");
							return false;
						}
					}
					
					if(colIdx == 0)
					{
						rowData = _content.addRow(rowCol.text());
						if(rowData == null)
						{
							this.txtOutput.appendText("第"+(rowIdx+1)+"行，重复的key："+rowCol.text()+"\n");
							return false;
						}
					}
					
					++colIdx;
					
					rowData.push(rowCol.text());
				}
				
				if(!rowData || rowData.length != _content.colNum())
				{
					this.txtOutput.appendText("第"+(rowIdx+1)+"行，数据列数不足"+_content.colNum()+"\n");
					return false;
				}
				
				//记录标志位
				colInited = true;
				++rowIdx;
			}
			
			return true;
		}
		
		function parseTxt(f:File):Boolean{
			return false;
		}
		
		function parseBin(f:File):void{
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.READ);
			var msg:TconfTable = new TconfTable;
			msg.mergeFrom(fs);
			fs.close();
			
			//toString 会报错，以上先山寨显示，用protoc.exe直接看比较好
			this.txtOutput.appendText(msg.toString());
			this.txtOutput.appendText("\n");
		}
	}
	
}
