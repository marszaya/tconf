package  {
	import com.netease.protobuf.*;
	use namespace com.netease.protobuf.used_by_generated_code;
	import com.netease.protobuf.fieldDescriptors.*;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.errors.IOError;
	import TconfColDef;
	import TconfRow;
	// @@protoc_insertion_point(imports)

	// @@protoc_insertion_point(class_metadata)
	public dynamic final class TconfTable extends com.netease.protobuf.Message {
		/**
		 *  @private
		 */
		public static const COLDEFS:RepeatedFieldDescriptor$TYPE_MESSAGE = new RepeatedFieldDescriptor$TYPE_MESSAGE("TconfTable.colDefs", "colDefs", (1 << 3) | com.netease.protobuf.WireType.LENGTH_DELIMITED, function():Class { return TconfColDef; });

		[ArrayElementType("TconfColDef")]
		public var colDefs:Array = [];

		/**
		 *  @private
		 */
		public static const ROWS:RepeatedFieldDescriptor$TYPE_MESSAGE = new RepeatedFieldDescriptor$TYPE_MESSAGE("TconfTable.rows", "rows", (2 << 3) | com.netease.protobuf.WireType.LENGTH_DELIMITED, function():Class { return TconfRow; });

		[ArrayElementType("TconfRow")]
		public var rows:Array = [];

		/**
		 *  @private
		 */
		override com.netease.protobuf.used_by_generated_code final function writeToBuffer(output:com.netease.protobuf.WritingBuffer):void {
			for (var colDefs$index:uint = 0; colDefs$index < this.colDefs.length; ++colDefs$index) {
				com.netease.protobuf.WriteUtils.writeTag(output, com.netease.protobuf.WireType.LENGTH_DELIMITED, 1);
				com.netease.protobuf.WriteUtils.write$TYPE_MESSAGE(output, this.colDefs[colDefs$index]);
			}
			for (var rows$index:uint = 0; rows$index < this.rows.length; ++rows$index) {
				com.netease.protobuf.WriteUtils.writeTag(output, com.netease.protobuf.WireType.LENGTH_DELIMITED, 2);
				com.netease.protobuf.WriteUtils.write$TYPE_MESSAGE(output, this.rows[rows$index]);
			}
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		/**
		 *  @private
		 */
		override com.netease.protobuf.used_by_generated_code final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.netease.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					this.colDefs.push(com.netease.protobuf.ReadUtils.read$TYPE_MESSAGE(input, new TconfColDef()));
					break;
				case 2:
					this.rows.push(com.netease.protobuf.ReadUtils.read$TYPE_MESSAGE(input, new TconfRow()));
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
