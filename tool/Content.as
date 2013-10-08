package  {
	import flash.utils.Dictionary;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	public class Content {

		public var lineCache:Dictionary;
		public var saveColArray:Array;
		public var lineCacheRowNum:int;
		public var tagName:String;
		
		public function Content() {
			// constructor code
			lineCache = null;
			saveColArray = null;
			lineCacheRowNum = 0;
			reset();
		}
		
		public function reset():void
		{
			lineCache = new Dictionary;
			saveColArray = new Array;
			lineCacheRowNum = 0;
		}
		
		public function addColName(s:String):Boolean
		{
			if(colNameInArray(s))
			{
				return false;
			}
			saveColArray.push(s);
			return true;
		}
		
		public function colNum():int
		{
			return saveColArray.length;
		}

		public function colNameInArray(s:String):Boolean{
			for each(var ss:String in saveColArray)
			{
				if(s==ss)
					return true;
			}
			return false;
		}
		
		public function addRow(key:String):Array
		{
			var ret:Array = new Array;
			if(lineCache[key])
			{
				return null;
			}
			
			lineCache[key] = ret;
			++lineCacheRowNum;
			return ret;
		}
		
		public function summary():String
		{
			var ret:String = "列名：";
			for each(var colName:String in saveColArray)
			{
				ret += " ["+colName+"]";
			}
			ret += "\n数据行数："+lineCacheRowNum+"\n";
			return ret;
		}
		
		public function colNameAt(idx:int):String
		{
			if(idx >= saveColArray.length || idx < 0)
				return "";
			return saveColArray[idx] as String;
		}
		
		public function dumpToXML():XML
		{
			var xmlObj:XML = <tconf version="1.0"><dict></dict></tconf>;
			var curXml:XML = xmlObj.dict[0];
			for(var rowKey:String in lineCache)
			{
				curXml.appendChild(new XML("<key>"+rowKey+"</key>"));
				var rowXml:XML = new XML("<dict></dict>");
				var rowArray:Array = lineCache[rowKey];
				
				for(var idx:int =0; idx<saveColArray.length; ++idx)
				{
					rowXml.appendChild(new XML("<key>"+saveColArray[idx]+"</key>"));
					rowXml.appendChild(new XML("<string>"+rowArray[idx]+"</string>"));
				}
				
				
				curXml.appendChild(rowXml);
			}
			return xmlObj;
		}
		
		public function createProto(out:IDataOutput):void
		{
			var msg:TconfTable = new TconfTable;
			
			for(var idx:int =0; idx<saveColArray.length; ++idx)
			{
				var msgCol:TconfColDef = new TconfColDef;
				msgCol.type = "string";
				msgCol.name = saveColArray[idx];
				msg.colDefs.push(msgCol);
			}
			
			for each(var rowArray:Array in lineCache)
			{
				var msgRow:TconfRow = new TconfRow;
				for(var i:int=0; i<rowArray.length; ++i)
				{
					msgRow.values.push(rowArray[i]);
				}
				
				msg.rows.push(msgRow);
			}
			
			msg.writeTo(out);
		}
		
		public function createAS():String{
			var ret:String = "package  {\n";
			ret += "\tpublic class "+tagName+" extends TconfHelper {\n";
			
			//静态定义
			for(var idx:int =0; idx<saveColArray.length; ++idx)
			{
				ret += "\t\tpublic static const "+ (saveColArray[idx] as String).toUpperCase() +":String=\""+saveColArray[idx]+"\";\n";
			}
			
			//manager引用定义
			ret += "\t\tprivate var _mg:ITconfManager;\n\n";
			
			//构造函数
			ret += "\t\tpublic function "+tagName+"(m:ITconfManager, url:String, idxCol:int=-1) {\n";
			ret +=	"\t\t\t_mg=m;\n";
			ret +=	"\t\t\tsuper(url, idxCol);\n";
			ret += "\t\t}\n";
			
			//自检函数
			ret += "\t\toverride public function selfCheck():void{\n";
			for(var idx:int =0; idx<saveColArray.length; ++idx)
			{
				ret += "\t\t\tgetColIdx("+ (saveColArray[idx] as String).toUpperCase() +");\n";
			} 

				//通知manager加载完成
			ret += "\t\t\t_mg.onTconfLoaded(\""+tagName+"\");\n";
			ret += "\t\t}\n";
			
			ret += "\t}\n";
			ret += "}\n";
			
			return ret;
		}
		
		public function createH():String{
			var className:String = "C"+tagName;
			var ret:String =  "#pragma once\n";
			ret += "#include \"tconfHelper.h\"\n";
			ret += "class "+className+" : public CTconfHelper\n{\n";
			ret += "public:\n";
			
			//静态定义
			for(var idx:int =0; idx<saveColArray.length; ++idx)
			{
				ret += "\tconst char* "+ (saveColArray[idx] as String).toUpperCase()+";\n";
			}
						
			//构造函数
			ret += "\n\t"+className+"(const char* binFilePath, int colIdx=-1)\n\t{\n";
			for(var idx:int =0; idx<saveColArray.length; ++idx)
			{
				ret += "\t\t"+ (saveColArray[idx] as String).toUpperCase()+"=\""+saveColArray[idx]+"\";\n";
			}
			ret +=	"\t\t\init(binFilePath, colIdx);\n";
			ret += "\t}\n\n";
			
			//自检函数
			ret += "\tvirtual int selfCheck()\n\t{\n";
			for(var idx:int =0; idx<saveColArray.length; ++idx)
			{
				ret += "\t\tif(getColIdx("+ (saveColArray[idx] as String).toUpperCase() +")<0) return -1;\n";
			} 

			ret += "\t\treturn 0;\n";
			ret += "\t}\n";
			
			ret += "};\n\n";
		
			return ret;

		}

	}
	
}
