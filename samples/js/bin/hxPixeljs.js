(function () { "use strict";
var $hxClasses = {},$estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function inherit() {}; inherit.prototype = from; var proto = new inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { }
$hxClasses["HxOverrides"] = HxOverrides;
HxOverrides.__name__ = true;
HxOverrides.strDate = function(s) {
	switch(s.length) {
	case 8:
		var k = s.split(":");
		var d = new Date();
		d.setTime(0);
		d.setUTCHours(k[0]);
		d.setUTCMinutes(k[1]);
		d.setUTCSeconds(k[2]);
		return d;
	case 10:
		var k = s.split("-");
		return new Date(k[0],k[1] - 1,k[2],0,0,0);
	case 19:
		var k = s.split(" ");
		var y = k[0].split("-");
		var t = k[1].split(":");
		return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
	default:
		throw "Invalid date format : " + s;
	}
}
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
}
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
}
var List = function() {
	this.length = 0;
};
$hxClasses["List"] = List;
List.__name__ = true;
List.prototype = {
	add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,__class__: List
}
var Main = function() { }
$hxClasses["Main"] = Main;
Main.__name__ = true;
Main.main = function() {
	var document = js.Browser.document;
	var canvas = document.createElement("canvas");
	canvas.width = 100;
	canvas.height = 100;
	document.body.appendChild(canvas);
	var context = canvas.getContext("2d");
	context.fillStyle = "#FFF";
	context.fillRect(0,0,40,40);
	var gifBytes = haxe.Resource.getBytes("16x16_16colors_001_gif");
	var gifImage = Main.createGifImage(gifBytes,context);
	context.putImageData(gifImage,1,1);
	var pngBytes = haxe.Resource.getBytes("16x16_16colors_001_png");
	var pngImage = Main.createPngImage(pngBytes,context);
	context.putImageData(pngImage,18,0);
}
Main.createPngImage = function(bytes,context) {
	var pnginfo = hxpixel.images.png.PngDecoder.decode(bytes);
	console.log("width: " + pnginfo.width);
	console.log("height: " + pnginfo.height);
	console.log("colorType: " + Std.string(pnginfo.colotType));
	console.log("filterMethod: " + Std.string(pnginfo.filterMethod));
	console.log("bitDepth: " + pnginfo.bitDepth);
	var pngImage = context.createImageData(pnginfo.width,pnginfo.height);
	var rgbaImageData = pnginfo.getRgbaImageData();
	var pos = 0;
	var imageDataPos = 0;
	var _g1 = 0, _g = pnginfo.height;
	while(_g1 < _g) {
		var y = _g1++;
		var _g3 = 0, _g2 = pnginfo.width;
		while(_g3 < _g2) {
			var x = _g3++;
			var rgba = rgbaImageData[pos];
			pngImage.data[imageDataPos++] = rgba >> 16 & 255;
			pngImage.data[imageDataPos++] = rgba >> 8 & 255;
			pngImage.data[imageDataPos++] = rgba & 255;
			pngImage.data[imageDataPos++] = rgba >> 24 & 255;
			++pos;
		}
	}
	return pngImage;
}
Main.createGifImage = function(bytes,context) {
	var gifinfo = hxpixel.images.gif.GifDecoder.decode(bytes);
	console.log("width: " + gifinfo.logicalScreenWidth);
	console.log("height: " + gifinfo.logicalScreenHeight);
	console.log("colorResolution: " + gifinfo.colorResolution);
	console.log("globalColotTableFlag:" + Std.string(gifinfo.globalColorTableFlag));
	console.log("globalColotTable:" + Std.string(gifinfo.globalColorTable));
	console.log("numFrames: " + gifinfo.get_numFrames());
	var _g1 = 0, _g = gifinfo.get_numFrames();
	while(_g1 < _g) {
		var i = _g1++;
		var gifFrameInfo = gifinfo.frameList[i];
		console.log("imageWidth: " + gifFrameInfo.imageWidth);
		console.log("imageHeight: " + gifFrameInfo.imageHeight);
		console.log("localColorTable:" + Std.string(gifFrameInfo.localColorTable));
	}
	var gifFrameInfo = gifinfo.frameList[0];
	var gifImage = context.createImageData(gifFrameInfo.imageWidth,gifFrameInfo.imageHeight);
	var rgbaImageData = gifFrameInfo.getRgbaImageData();
	var pos = 0;
	var imageDataPos = 0;
	var _g1 = 0, _g = gifFrameInfo.imageHeight;
	while(_g1 < _g) {
		var y = _g1++;
		var _g3 = 0, _g2 = gifFrameInfo.imageWidth;
		while(_g3 < _g2) {
			var x = _g3++;
			var rgba = rgbaImageData[pos];
			gifImage.data[imageDataPos++] = rgba >> 16 & 255;
			gifImage.data[imageDataPos++] = rgba >> 8 & 255;
			gifImage.data[imageDataPos++] = rgba & 255;
			gifImage.data[imageDataPos++] = rgba >> 24 & 255;
			++pos;
		}
	}
	return gifImage;
}
var IMap = function() { }
$hxClasses["IMap"] = IMap;
IMap.__name__ = true;
var Reflect = function() { }
$hxClasses["Reflect"] = Reflect;
Reflect.__name__ = true;
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	} catch( e ) {
	}
	return v;
}
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
}
var Std = function() { }
$hxClasses["Std"] = Std;
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
var StringTools = function() { }
$hxClasses["StringTools"] = StringTools;
StringTools.__name__ = true;
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.hex = function(n,digits) {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(n & 15) + s;
		n >>>= 4;
	} while(n > 0);
	if(digits != null) while(s.length < digits) s = "0" + s;
	return s;
}
var Type = function() { }
$hxClasses["Type"] = Type;
Type.__name__ = true;
Type.resolveClass = function(name) {
	var cl = $hxClasses[name];
	if(cl == null || !cl.__name__) return null;
	return cl;
}
Type.resolveEnum = function(name) {
	var e = $hxClasses[name];
	if(e == null || !e.__ename__) return null;
	return e;
}
Type.createEmptyInstance = function(cl) {
	function empty() {}; empty.prototype = cl.prototype;
	return new empty();
}
Type.createEnum = function(e,constr,params) {
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw "Constructor " + constr + " need parameters";
		return f.apply(e,params);
	}
	if(params != null && params.length != 0) throw "Constructor " + constr + " does not need parameters";
	return f;
}
Type.getEnumConstructs = function(e) {
	var a = e.__constructs__;
	return a.slice();
}
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		var _g1 = 2, _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) return false;
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	} catch( e ) {
		return false;
	}
	return true;
}
var haxe = {}
haxe.Resource = function() { }
$hxClasses["haxe.Resource"] = haxe.Resource;
haxe.Resource.__name__ = true;
haxe.Resource.getBytes = function(name) {
	var _g = 0, _g1 = haxe.Resource.content;
	while(_g < _g1.length) {
		var x = _g1[_g];
		++_g;
		if(x.name == name) {
			if(x.str != null) return haxe.io.Bytes.ofString(x.str);
			return haxe.Unserializer.run(x.data);
		}
	}
	return null;
}
haxe.Unserializer = function(buf) {
	this.buf = buf;
	this.length = buf.length;
	this.pos = 0;
	this.scache = new Array();
	this.cache = new Array();
	var r = haxe.Unserializer.DEFAULT_RESOLVER;
	if(r == null) {
		r = Type;
		haxe.Unserializer.DEFAULT_RESOLVER = r;
	}
	this.setResolver(r);
};
$hxClasses["haxe.Unserializer"] = haxe.Unserializer;
haxe.Unserializer.__name__ = true;
haxe.Unserializer.initCodes = function() {
	var codes = new Array();
	var _g1 = 0, _g = haxe.Unserializer.BASE64.length;
	while(_g1 < _g) {
		var i = _g1++;
		codes[haxe.Unserializer.BASE64.charCodeAt(i)] = i;
	}
	return codes;
}
haxe.Unserializer.run = function(v) {
	return new haxe.Unserializer(v).unserialize();
}
haxe.Unserializer.prototype = {
	unserialize: function() {
		var _g = this.buf.charCodeAt(this.pos++);
		switch(_g) {
		case 110:
			return null;
		case 116:
			return true;
		case 102:
			return false;
		case 122:
			return 0;
		case 105:
			return this.readDigits();
		case 100:
			var p1 = this.pos;
			while(true) {
				var c = this.buf.charCodeAt(this.pos);
				if(c >= 43 && c < 58 || c == 101 || c == 69) this.pos++; else break;
			}
			return Std.parseFloat(HxOverrides.substr(this.buf,p1,this.pos - p1));
		case 121:
			var len = this.readDigits();
			if(this.buf.charCodeAt(this.pos++) != 58 || this.length - this.pos < len) throw "Invalid string length";
			var s = HxOverrides.substr(this.buf,this.pos,len);
			this.pos += len;
			s = StringTools.urlDecode(s);
			this.scache.push(s);
			return s;
		case 107:
			return Math.NaN;
		case 109:
			return Math.NEGATIVE_INFINITY;
		case 112:
			return Math.POSITIVE_INFINITY;
		case 97:
			var buf = this.buf;
			var a = new Array();
			this.cache.push(a);
			while(true) {
				var c = this.buf.charCodeAt(this.pos);
				if(c == 104) {
					this.pos++;
					break;
				}
				if(c == 117) {
					this.pos++;
					var n = this.readDigits();
					a[a.length + n - 1] = null;
				} else a.push(this.unserialize());
			}
			return a;
		case 111:
			var o = { };
			this.cache.push(o);
			this.unserializeObject(o);
			return o;
		case 114:
			var n = this.readDigits();
			if(n < 0 || n >= this.cache.length) throw "Invalid reference";
			return this.cache[n];
		case 82:
			var n = this.readDigits();
			if(n < 0 || n >= this.scache.length) throw "Invalid string reference";
			return this.scache[n];
		case 120:
			throw this.unserialize();
			break;
		case 99:
			var name = this.unserialize();
			var cl = this.resolver.resolveClass(name);
			if(cl == null) throw "Class not found " + name;
			var o = Type.createEmptyInstance(cl);
			this.cache.push(o);
			this.unserializeObject(o);
			return o;
		case 119:
			var name = this.unserialize();
			var edecl = this.resolver.resolveEnum(name);
			if(edecl == null) throw "Enum not found " + name;
			var e = this.unserializeEnum(edecl,this.unserialize());
			this.cache.push(e);
			return e;
		case 106:
			var name = this.unserialize();
			var edecl = this.resolver.resolveEnum(name);
			if(edecl == null) throw "Enum not found " + name;
			this.pos++;
			var index = this.readDigits();
			var tag = Type.getEnumConstructs(edecl)[index];
			if(tag == null) throw "Unknown enum index " + name + "@" + index;
			var e = this.unserializeEnum(edecl,tag);
			this.cache.push(e);
			return e;
		case 108:
			var l = new List();
			this.cache.push(l);
			var buf = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) l.add(this.unserialize());
			this.pos++;
			return l;
		case 98:
			var h = new haxe.ds.StringMap();
			this.cache.push(h);
			var buf = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) {
				var s = this.unserialize();
				h.set(s,this.unserialize());
			}
			this.pos++;
			return h;
		case 113:
			var h = new haxe.ds.IntMap();
			this.cache.push(h);
			var buf = this.buf;
			var c = this.buf.charCodeAt(this.pos++);
			while(c == 58) {
				var i = this.readDigits();
				h.set(i,this.unserialize());
				c = this.buf.charCodeAt(this.pos++);
			}
			if(c != 104) throw "Invalid IntMap format";
			return h;
		case 77:
			var h = new haxe.ds.ObjectMap();
			this.cache.push(h);
			var buf = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) {
				var s = this.unserialize();
				h.set(s,this.unserialize());
			}
			this.pos++;
			return h;
		case 118:
			var d = HxOverrides.strDate(HxOverrides.substr(this.buf,this.pos,19));
			this.cache.push(d);
			this.pos += 19;
			return d;
		case 115:
			var len = this.readDigits();
			var buf = this.buf;
			if(this.buf.charCodeAt(this.pos++) != 58 || this.length - this.pos < len) throw "Invalid bytes length";
			var codes = haxe.Unserializer.CODES;
			if(codes == null) {
				codes = haxe.Unserializer.initCodes();
				haxe.Unserializer.CODES = codes;
			}
			var i = this.pos;
			var rest = len & 3;
			var size = (len >> 2) * 3 + (rest >= 2?rest - 1:0);
			var max = i + (len - rest);
			var bytes = haxe.io.Bytes.alloc(size);
			var bpos = 0;
			while(i < max) {
				var c1 = codes[buf.charCodeAt(i++)];
				var c2 = codes[buf.charCodeAt(i++)];
				bytes.b[bpos++] = (c1 << 2 | c2 >> 4) & 255;
				var c3 = codes[buf.charCodeAt(i++)];
				bytes.b[bpos++] = (c2 << 4 | c3 >> 2) & 255;
				var c4 = codes[buf.charCodeAt(i++)];
				bytes.b[bpos++] = (c3 << 6 | c4) & 255;
			}
			if(rest >= 2) {
				var c1 = codes[buf.charCodeAt(i++)];
				var c2 = codes[buf.charCodeAt(i++)];
				bytes.b[bpos++] = (c1 << 2 | c2 >> 4) & 255;
				if(rest == 3) {
					var c3 = codes[buf.charCodeAt(i++)];
					bytes.b[bpos++] = (c2 << 4 | c3 >> 2) & 255;
				}
			}
			this.pos += len;
			this.cache.push(bytes);
			return bytes;
		case 67:
			var name = this.unserialize();
			var cl = this.resolver.resolveClass(name);
			if(cl == null) throw "Class not found " + name;
			var o = Type.createEmptyInstance(cl);
			this.cache.push(o);
			o.hxUnserialize(this);
			if(this.buf.charCodeAt(this.pos++) != 103) throw "Invalid custom data";
			return o;
		default:
		}
		this.pos--;
		throw "Invalid char " + this.buf.charAt(this.pos) + " at position " + this.pos;
	}
	,unserializeEnum: function(edecl,tag) {
		if(this.buf.charCodeAt(this.pos++) != 58) throw "Invalid enum format";
		var nargs = this.readDigits();
		if(nargs == 0) return Type.createEnum(edecl,tag);
		var args = new Array();
		while(nargs-- > 0) args.push(this.unserialize());
		return Type.createEnum(edecl,tag,args);
	}
	,unserializeObject: function(o) {
		while(true) {
			if(this.pos >= this.length) throw "Invalid object";
			if(this.buf.charCodeAt(this.pos) == 103) break;
			var k = this.unserialize();
			if(!js.Boot.__instanceof(k,String)) throw "Invalid object key";
			var v = this.unserialize();
			o[k] = v;
		}
		this.pos++;
	}
	,readDigits: function() {
		var k = 0;
		var s = false;
		var fpos = this.pos;
		while(true) {
			var c = this.buf.charCodeAt(this.pos);
			if(c != c) break;
			if(c == 45) {
				if(this.pos != fpos) break;
				s = true;
				this.pos++;
				continue;
			}
			if(c < 48 || c > 57) break;
			k = k * 10 + (c - 48);
			this.pos++;
		}
		if(s) k *= -1;
		return k;
	}
	,setResolver: function(r) {
		if(r == null) this.resolver = { resolveClass : function(_) {
			return null;
		}, resolveEnum : function(_) {
			return null;
		}}; else this.resolver = r;
	}
	,__class__: haxe.Unserializer
}
haxe.crypto = {}
haxe.crypto.Adler32 = function() {
	this.a1 = 1;
	this.a2 = 0;
};
$hxClasses["haxe.crypto.Adler32"] = haxe.crypto.Adler32;
haxe.crypto.Adler32.__name__ = true;
haxe.crypto.Adler32.read = function(i) {
	var a = new haxe.crypto.Adler32();
	var a2a = i.readByte();
	var a2b = i.readByte();
	var a1a = i.readByte();
	var a1b = i.readByte();
	a.a1 = a1a << 8 | a1b;
	a.a2 = a2a << 8 | a2b;
	return a;
}
haxe.crypto.Adler32.prototype = {
	equals: function(a) {
		return a.a1 == this.a1 && a.a2 == this.a2;
	}
	,update: function(b,pos,len) {
		var a1 = this.a1, a2 = this.a2;
		var _g1 = pos, _g = pos + len;
		while(_g1 < _g) {
			var p = _g1++;
			var c = b.b[p];
			a1 = (a1 + c) % 65521;
			a2 = (a2 + a1) % 65521;
		}
		this.a1 = a1;
		this.a2 = a2;
	}
	,__class__: haxe.crypto.Adler32
}
haxe.ds = {}
haxe.ds.IntMap = function() {
	this.h = { };
};
$hxClasses["haxe.ds.IntMap"] = haxe.ds.IntMap;
haxe.ds.IntMap.__name__ = true;
haxe.ds.IntMap.__interfaces__ = [IMap];
haxe.ds.IntMap.prototype = {
	exists: function(key) {
		return this.h.hasOwnProperty(key);
	}
	,get: function(key) {
		return this.h[key];
	}
	,set: function(key,value) {
		this.h[key] = value;
	}
	,__class__: haxe.ds.IntMap
}
haxe.ds.ObjectMap = function() {
	this.h = { };
	this.h.__keys__ = { };
};
$hxClasses["haxe.ds.ObjectMap"] = haxe.ds.ObjectMap;
haxe.ds.ObjectMap.__name__ = true;
haxe.ds.ObjectMap.__interfaces__ = [IMap];
haxe.ds.ObjectMap.prototype = {
	set: function(key,value) {
		var id = key.__id__ != null?key.__id__:key.__id__ = ++haxe.ds.ObjectMap.count;
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,__class__: haxe.ds.ObjectMap
}
haxe.ds.StringMap = function() {
	this.h = { };
};
$hxClasses["haxe.ds.StringMap"] = haxe.ds.StringMap;
haxe.ds.StringMap.__name__ = true;
haxe.ds.StringMap.__interfaces__ = [IMap];
haxe.ds.StringMap.prototype = {
	set: function(key,value) {
		this.h["$" + key] = value;
	}
	,__class__: haxe.ds.StringMap
}
haxe.io = {}
haxe.io.Input = function() { }
$hxClasses["haxe.io.Input"] = haxe.io.Input;
haxe.io.Input.__name__ = true;
haxe.io.Input.prototype = {
	readString: function(len) {
		var b = haxe.io.Bytes.alloc(len);
		this.readFullBytes(b,0,len);
		return b.toString();
	}
	,readInt32: function() {
		var ch1 = this.readByte();
		var ch2 = this.readByte();
		var ch3 = this.readByte();
		var ch4 = this.readByte();
		return this.bigEndian?ch4 | ch3 << 8 | ch2 << 16 | ch1 << 24:ch1 | ch2 << 8 | ch3 << 16 | ch4 << 24;
	}
	,readUInt16: function() {
		var ch1 = this.readByte();
		var ch2 = this.readByte();
		return this.bigEndian?ch2 | ch1 << 8:ch1 | ch2 << 8;
	}
	,readInt16: function() {
		var ch1 = this.readByte();
		var ch2 = this.readByte();
		var n = this.bigEndian?ch2 | ch1 << 8:ch1 | ch2 << 8;
		if((n & 32768) != 0) return n - 65536;
		return n;
	}
	,readInt8: function() {
		var n = this.readByte();
		if(n >= 128) return n - 256;
		return n;
	}
	,read: function(nbytes) {
		var s = haxe.io.Bytes.alloc(nbytes);
		var p = 0;
		while(nbytes > 0) {
			var k = this.readBytes(s,p,nbytes);
			if(k == 0) throw haxe.io.Error.Blocked;
			p += k;
			nbytes -= k;
		}
		return s;
	}
	,readFullBytes: function(s,pos,len) {
		while(len > 0) {
			var k = this.readBytes(s,pos,len);
			pos += k;
			len -= k;
		}
	}
	,set_bigEndian: function(b) {
		this.bigEndian = b;
		return b;
	}
	,readBytes: function(s,pos,len) {
		var k = len;
		var b = s.b;
		if(pos < 0 || len < 0 || pos + len > s.length) throw haxe.io.Error.OutsideBounds;
		while(k > 0) {
			b[pos] = this.readByte();
			pos++;
			k--;
		}
		return len;
	}
	,readByte: function() {
		return (function($this) {
			var $r;
			throw "Not implemented";
			return $r;
		}(this));
	}
	,__class__: haxe.io.Input
}
haxe.io.Bytes = function(length,b) {
	this.length = length;
	this.b = b;
};
$hxClasses["haxe.io.Bytes"] = haxe.io.Bytes;
haxe.io.Bytes.__name__ = true;
haxe.io.Bytes.alloc = function(length) {
	var a = new Array();
	var _g = 0;
	while(_g < length) {
		var i = _g++;
		a.push(0);
	}
	return new haxe.io.Bytes(length,a);
}
haxe.io.Bytes.ofString = function(s) {
	var a = new Array();
	var _g1 = 0, _g = s.length;
	while(_g1 < _g) {
		var i = _g1++;
		var c = s.charCodeAt(i);
		if(c <= 127) a.push(c); else if(c <= 2047) {
			a.push(192 | c >> 6);
			a.push(128 | c & 63);
		} else if(c <= 65535) {
			a.push(224 | c >> 12);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		} else {
			a.push(240 | c >> 18);
			a.push(128 | c >> 12 & 63);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		}
	}
	return new haxe.io.Bytes(a.length,a);
}
haxe.io.Bytes.prototype = {
	toString: function() {
		return this.readString(0,this.length);
	}
	,readString: function(pos,len) {
		if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
		var s = "";
		var b = this.b;
		var fcc = String.fromCharCode;
		var i = pos;
		var max = pos + len;
		while(i < max) {
			var c = b[i++];
			if(c < 128) {
				if(c == 0) break;
				s += fcc(c);
			} else if(c < 224) s += fcc((c & 63) << 6 | b[i++] & 127); else if(c < 240) {
				var c2 = b[i++];
				s += fcc((c & 31) << 12 | (c2 & 127) << 6 | b[i++] & 127);
			} else {
				var c2 = b[i++];
				var c3 = b[i++];
				s += fcc((c & 15) << 18 | (c2 & 127) << 12 | c3 << 6 & 127 | b[i++] & 127);
			}
		}
		return s;
	}
	,blit: function(pos,src,srcpos,len) {
		if(pos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length) throw haxe.io.Error.OutsideBounds;
		var b1 = this.b;
		var b2 = src.b;
		if(b1 == b2 && pos > srcpos) {
			var i = len;
			while(i > 0) {
				i--;
				b1[i + pos] = b2[i + srcpos];
			}
			return;
		}
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			b1[i + pos] = b2[i + srcpos];
		}
	}
	,__class__: haxe.io.Bytes
}
haxe.io.BytesBuffer = function() {
	this.b = new Array();
};
$hxClasses["haxe.io.BytesBuffer"] = haxe.io.BytesBuffer;
haxe.io.BytesBuffer.__name__ = true;
haxe.io.BytesBuffer.prototype = {
	getBytes: function() {
		var bytes = new haxe.io.Bytes(this.b.length,this.b);
		this.b = null;
		return bytes;
	}
	,addBytes: function(src,pos,len) {
		if(pos < 0 || len < 0 || pos + len > src.length) throw haxe.io.Error.OutsideBounds;
		var b1 = this.b;
		var b2 = src.b;
		var _g1 = pos, _g = pos + len;
		while(_g1 < _g) {
			var i = _g1++;
			this.b.push(b2[i]);
		}
	}
	,__class__: haxe.io.BytesBuffer
}
haxe.io.BytesInput = function(b,pos,len) {
	if(pos == null) pos = 0;
	if(len == null) len = b.length - pos;
	if(pos < 0 || len < 0 || pos + len > b.length) throw haxe.io.Error.OutsideBounds;
	this.b = b.b;
	this.pos = pos;
	this.len = len;
};
$hxClasses["haxe.io.BytesInput"] = haxe.io.BytesInput;
haxe.io.BytesInput.__name__ = true;
haxe.io.BytesInput.__super__ = haxe.io.Input;
haxe.io.BytesInput.prototype = $extend(haxe.io.Input.prototype,{
	readBytes: function(buf,pos,len) {
		if(pos < 0 || len < 0 || pos + len > buf.length) throw haxe.io.Error.OutsideBounds;
		if(this.len == 0 && len > 0) throw new haxe.io.Eof();
		if(this.len < len) len = this.len;
		var b1 = this.b;
		var b2 = buf.b;
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			b2[pos + i] = b1[this.pos + i];
		}
		this.pos += len;
		this.len -= len;
		return len;
	}
	,readByte: function() {
		if(this.len == 0) throw new haxe.io.Eof();
		this.len--;
		return this.b[this.pos++];
	}
	,__class__: haxe.io.BytesInput
});
haxe.io.Output = function() { }
$hxClasses["haxe.io.Output"] = haxe.io.Output;
haxe.io.Output.__name__ = true;
haxe.io.BytesOutput = function() {
	this.b = new haxe.io.BytesBuffer();
};
$hxClasses["haxe.io.BytesOutput"] = haxe.io.BytesOutput;
haxe.io.BytesOutput.__name__ = true;
haxe.io.BytesOutput.__super__ = haxe.io.Output;
haxe.io.BytesOutput.prototype = $extend(haxe.io.Output.prototype,{
	getBytes: function() {
		return this.b.getBytes();
	}
	,writeBytes: function(buf,pos,len) {
		this.b.addBytes(buf,pos,len);
		return len;
	}
	,writeByte: function(c) {
		this.b.b.push(c);
	}
	,__class__: haxe.io.BytesOutput
});
haxe.io.Eof = function() {
};
$hxClasses["haxe.io.Eof"] = haxe.io.Eof;
haxe.io.Eof.__name__ = true;
haxe.io.Eof.prototype = {
	toString: function() {
		return "Eof";
	}
	,__class__: haxe.io.Eof
}
haxe.io.Error = $hxClasses["haxe.io.Error"] = { __ename__ : true, __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] }
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; }
haxe.zip = {}
haxe.zip.Huffman = $hxClasses["haxe.zip.Huffman"] = { __ename__ : true, __constructs__ : ["Found","NeedBit","NeedBits"] }
haxe.zip.Huffman.Found = function(i) { var $x = ["Found",0,i]; $x.__enum__ = haxe.zip.Huffman; $x.toString = $estr; return $x; }
haxe.zip.Huffman.NeedBit = function(left,right) { var $x = ["NeedBit",1,left,right]; $x.__enum__ = haxe.zip.Huffman; $x.toString = $estr; return $x; }
haxe.zip.Huffman.NeedBits = function(n,table) { var $x = ["NeedBits",2,n,table]; $x.__enum__ = haxe.zip.Huffman; $x.toString = $estr; return $x; }
haxe.zip.HuffTools = function() {
};
$hxClasses["haxe.zip.HuffTools"] = haxe.zip.HuffTools;
haxe.zip.HuffTools.__name__ = true;
haxe.zip.HuffTools.prototype = {
	make: function(lengths,pos,nlengths,maxbits) {
		var counts = new Array();
		var tmp = new Array();
		if(maxbits > 32) throw "Invalid huffman";
		var _g = 0;
		while(_g < maxbits) {
			var i = _g++;
			counts.push(0);
			tmp.push(0);
		}
		var _g = 0;
		while(_g < nlengths) {
			var i = _g++;
			var p = lengths[i + pos];
			if(p >= maxbits) throw "Invalid huffman";
			counts[p]++;
		}
		var code = 0;
		var _g1 = 1, _g = maxbits - 1;
		while(_g1 < _g) {
			var i = _g1++;
			code = code + counts[i] << 1;
			tmp[i] = code;
		}
		var bits = new haxe.ds.IntMap();
		var _g = 0;
		while(_g < nlengths) {
			var i = _g++;
			var l = lengths[i + pos];
			if(l != 0) {
				var n = tmp[l - 1];
				tmp[l - 1] = n + 1;
				bits.set(n << 5 | l,i);
			}
		}
		return this.treeCompress(haxe.zip.Huffman.NeedBit(this.treeMake(bits,maxbits,0,1),this.treeMake(bits,maxbits,1,1)));
	}
	,treeMake: function(bits,maxbits,v,len) {
		if(len > maxbits) throw "Invalid huffman";
		var idx = v << 5 | len;
		if(bits.exists(idx)) return haxe.zip.Huffman.Found(bits.get(idx));
		v <<= 1;
		len += 1;
		return haxe.zip.Huffman.NeedBit(this.treeMake(bits,maxbits,v,len),this.treeMake(bits,maxbits,v | 1,len));
	}
	,treeWalk: function(table,p,cd,d,t) {
		var $e = (t);
		switch( $e[1] ) {
		case 1:
			var b = $e[3], a = $e[2];
			if(d > 0) {
				this.treeWalk(table,p,cd + 1,d - 1,a);
				this.treeWalk(table,p | 1 << cd,cd + 1,d - 1,b);
			} else table[p] = this.treeCompress(t);
			break;
		default:
			table[p] = this.treeCompress(t);
		}
	}
	,treeCompress: function(t) {
		var d = this.treeDepth(t);
		if(d == 0) return t;
		if(d == 1) return (function($this) {
			var $r;
			var $e = (t);
			switch( $e[1] ) {
			case 1:
				var b = $e[3], a = $e[2];
				$r = haxe.zip.Huffman.NeedBit($this.treeCompress(a),$this.treeCompress(b));
				break;
			default:
				$r = (function($this) {
					var $r;
					throw "assert";
					return $r;
				}($this));
			}
			return $r;
		}(this));
		var size = 1 << d;
		var table = new Array();
		var _g = 0;
		while(_g < size) {
			var i = _g++;
			table.push(haxe.zip.Huffman.Found(-1));
		}
		this.treeWalk(table,0,0,d,t);
		return haxe.zip.Huffman.NeedBits(d,table);
	}
	,treeDepth: function(t) {
		return (function($this) {
			var $r;
			var $e = (t);
			switch( $e[1] ) {
			case 0:
				$r = 0;
				break;
			case 2:
				$r = (function($this) {
					var $r;
					throw "assert";
					return $r;
				}($this));
				break;
			case 1:
				var b = $e[3], a = $e[2];
				$r = (function($this) {
					var $r;
					var da = $this.treeDepth(a);
					var db = $this.treeDepth(b);
					$r = 1 + (da < db?da:db);
					return $r;
				}($this));
				break;
			}
			return $r;
		}(this));
	}
	,__class__: haxe.zip.HuffTools
}
haxe.zip._InflateImpl = {}
haxe.zip._InflateImpl.Window = function(hasCrc) {
	this.buffer = haxe.io.Bytes.alloc(65536);
	this.pos = 0;
	if(hasCrc) this.crc = new haxe.crypto.Adler32();
};
$hxClasses["haxe.zip._InflateImpl.Window"] = haxe.zip._InflateImpl.Window;
haxe.zip._InflateImpl.Window.__name__ = true;
haxe.zip._InflateImpl.Window.prototype = {
	checksum: function() {
		if(this.crc != null) this.crc.update(this.buffer,0,this.pos);
		return this.crc;
	}
	,available: function() {
		return this.pos;
	}
	,getLastChar: function() {
		return this.buffer.b[this.pos - 1];
	}
	,addByte: function(c) {
		if(this.pos == 65536) this.slide();
		this.buffer.b[this.pos] = c & 255;
		this.pos++;
	}
	,addBytes: function(b,p,len) {
		if(this.pos + len > 65536) this.slide();
		this.buffer.blit(this.pos,b,p,len);
		this.pos += len;
	}
	,slide: function() {
		if(this.crc != null) this.crc.update(this.buffer,0,32768);
		var b = haxe.io.Bytes.alloc(65536);
		this.pos -= 32768;
		b.blit(0,this.buffer,32768,this.pos);
		this.buffer = b;
	}
	,__class__: haxe.zip._InflateImpl.Window
}
haxe.zip._InflateImpl.State = $hxClasses["haxe.zip._InflateImpl.State"] = { __ename__ : true, __constructs__ : ["Head","Block","CData","Flat","Crc","Dist","DistOne","Done"] }
haxe.zip._InflateImpl.State.Head = ["Head",0];
haxe.zip._InflateImpl.State.Head.toString = $estr;
haxe.zip._InflateImpl.State.Head.__enum__ = haxe.zip._InflateImpl.State;
haxe.zip._InflateImpl.State.Block = ["Block",1];
haxe.zip._InflateImpl.State.Block.toString = $estr;
haxe.zip._InflateImpl.State.Block.__enum__ = haxe.zip._InflateImpl.State;
haxe.zip._InflateImpl.State.CData = ["CData",2];
haxe.zip._InflateImpl.State.CData.toString = $estr;
haxe.zip._InflateImpl.State.CData.__enum__ = haxe.zip._InflateImpl.State;
haxe.zip._InflateImpl.State.Flat = ["Flat",3];
haxe.zip._InflateImpl.State.Flat.toString = $estr;
haxe.zip._InflateImpl.State.Flat.__enum__ = haxe.zip._InflateImpl.State;
haxe.zip._InflateImpl.State.Crc = ["Crc",4];
haxe.zip._InflateImpl.State.Crc.toString = $estr;
haxe.zip._InflateImpl.State.Crc.__enum__ = haxe.zip._InflateImpl.State;
haxe.zip._InflateImpl.State.Dist = ["Dist",5];
haxe.zip._InflateImpl.State.Dist.toString = $estr;
haxe.zip._InflateImpl.State.Dist.__enum__ = haxe.zip._InflateImpl.State;
haxe.zip._InflateImpl.State.DistOne = ["DistOne",6];
haxe.zip._InflateImpl.State.DistOne.toString = $estr;
haxe.zip._InflateImpl.State.DistOne.__enum__ = haxe.zip._InflateImpl.State;
haxe.zip._InflateImpl.State.Done = ["Done",7];
haxe.zip._InflateImpl.State.Done.toString = $estr;
haxe.zip._InflateImpl.State.Done.__enum__ = haxe.zip._InflateImpl.State;
haxe.zip.InflateImpl = function(i,header,crc) {
	if(crc == null) crc = true;
	if(header == null) header = true;
	this["final"] = false;
	this.htools = new haxe.zip.HuffTools();
	this.huffman = this.buildFixedHuffman();
	this.huffdist = null;
	this.len = 0;
	this.dist = 0;
	this.state = header?haxe.zip._InflateImpl.State.Head:haxe.zip._InflateImpl.State.Block;
	this.input = i;
	this.bits = 0;
	this.nbits = 0;
	this.needed = 0;
	this.output = null;
	this.outpos = 0;
	this.lengths = new Array();
	var _g = 0;
	while(_g < 19) {
		var i1 = _g++;
		this.lengths.push(-1);
	}
	this.window = new haxe.zip._InflateImpl.Window(crc);
};
$hxClasses["haxe.zip.InflateImpl"] = haxe.zip.InflateImpl;
haxe.zip.InflateImpl.__name__ = true;
haxe.zip.InflateImpl.run = function(i,bufsize) {
	if(bufsize == null) bufsize = 65536;
	var buf = haxe.io.Bytes.alloc(bufsize);
	var output = new haxe.io.BytesBuffer();
	var inflate = new haxe.zip.InflateImpl(i);
	while(true) {
		var len = inflate.readBytes(buf,0,bufsize);
		output.addBytes(buf,0,len);
		if(len < bufsize) break;
	}
	return output.getBytes();
}
haxe.zip.InflateImpl.prototype = {
	inflateLoop: function() {
		var _g = this;
		switch( (_g.state)[1] ) {
		case 0:
			var cmf = this.input.readByte();
			var cm = cmf & 15;
			var cinfo = cmf >> 4;
			if(cm != 8 || cinfo != 7) throw "Invalid data";
			var flg = this.input.readByte();
			var fdict = (flg & 32) != 0;
			if(((cmf << 8) + flg) % 31 != 0) throw "Invalid data";
			if(fdict) throw "Unsupported dictionary";
			this.state = haxe.zip._InflateImpl.State.Block;
			return true;
		case 4:
			var calc = this.window.checksum();
			if(calc == null) {
				this.state = haxe.zip._InflateImpl.State.Done;
				return true;
			}
			var crc = haxe.crypto.Adler32.read(this.input);
			if(!calc.equals(crc)) throw "Invalid CRC";
			this.state = haxe.zip._InflateImpl.State.Done;
			return true;
		case 7:
			return false;
		case 1:
			this["final"] = this.getBit();
			var _g1 = this.getBits(2);
			switch(_g1) {
			case 0:
				this.len = this.input.readUInt16();
				var nlen = this.input.readUInt16();
				if(nlen != 65535 - this.len) throw "Invalid data";
				this.state = haxe.zip._InflateImpl.State.Flat;
				var r = this.inflateLoop();
				this.resetBits();
				return r;
			case 1:
				this.huffman = this.buildFixedHuffman();
				this.huffdist = null;
				this.state = haxe.zip._InflateImpl.State.CData;
				return true;
			case 2:
				var hlit = this.getBits(5) + 257;
				var hdist = this.getBits(5) + 1;
				var hclen = this.getBits(4) + 4;
				var _g2 = 0;
				while(_g2 < hclen) {
					var i = _g2++;
					this.lengths[haxe.zip.InflateImpl.CODE_LENGTHS_POS[i]] = this.getBits(3);
				}
				var _g2 = hclen;
				while(_g2 < 19) {
					var i = _g2++;
					this.lengths[haxe.zip.InflateImpl.CODE_LENGTHS_POS[i]] = 0;
				}
				this.huffman = this.htools.make(this.lengths,0,19,8);
				var lengths = new Array();
				var _g3 = 0, _g2 = hlit + hdist;
				while(_g3 < _g2) {
					var i = _g3++;
					lengths.push(0);
				}
				this.inflateLengths(lengths,hlit + hdist);
				this.huffdist = this.htools.make(lengths,hlit,hdist,16);
				this.huffman = this.htools.make(lengths,0,hlit,16);
				this.state = haxe.zip._InflateImpl.State.CData;
				return true;
			default:
				throw "Invalid data";
			}
			break;
		case 3:
			var rlen = this.len < this.needed?this.len:this.needed;
			var bytes = this.input.read(rlen);
			this.len -= rlen;
			this.addBytes(bytes,0,rlen);
			if(this.len == 0) this.state = this["final"]?haxe.zip._InflateImpl.State.Crc:haxe.zip._InflateImpl.State.Block;
			return this.needed > 0;
		case 6:
			var rlen = this.len < this.needed?this.len:this.needed;
			this.addDistOne(rlen);
			this.len -= rlen;
			if(this.len == 0) this.state = haxe.zip._InflateImpl.State.CData;
			return this.needed > 0;
		case 5:
			while(this.len > 0 && this.needed > 0) {
				var rdist = this.len < this.dist?this.len:this.dist;
				var rlen = this.needed < rdist?this.needed:rdist;
				this.addDist(this.dist,rlen);
				this.len -= rlen;
			}
			if(this.len == 0) this.state = haxe.zip._InflateImpl.State.CData;
			return this.needed > 0;
		case 2:
			var n = this.applyHuffman(this.huffman);
			if(n < 256) {
				this.addByte(n);
				return this.needed > 0;
			} else if(n == 256) {
				this.state = this["final"]?haxe.zip._InflateImpl.State.Crc:haxe.zip._InflateImpl.State.Block;
				return true;
			} else {
				n -= 257;
				var extra_bits = haxe.zip.InflateImpl.LEN_EXTRA_BITS_TBL[n];
				if(extra_bits == -1) throw "Invalid data";
				this.len = haxe.zip.InflateImpl.LEN_BASE_VAL_TBL[n] + this.getBits(extra_bits);
				var dist_code = this.huffdist == null?this.getRevBits(5):this.applyHuffman(this.huffdist);
				extra_bits = haxe.zip.InflateImpl.DIST_EXTRA_BITS_TBL[dist_code];
				if(extra_bits == -1) throw "Invalid data";
				this.dist = haxe.zip.InflateImpl.DIST_BASE_VAL_TBL[dist_code] + this.getBits(extra_bits);
				if(this.dist > this.window.available()) throw "Invalid data";
				this.state = this.dist == 1?haxe.zip._InflateImpl.State.DistOne:haxe.zip._InflateImpl.State.Dist;
				return true;
			}
			break;
		}
	}
	,inflateLengths: function(a,max) {
		var i = 0;
		var prev = 0;
		while(i < max) {
			var n = this.applyHuffman(this.huffman);
			switch(n) {
			case 0:case 1:case 2:case 3:case 4:case 5:case 6:case 7:case 8:case 9:case 10:case 11:case 12:case 13:case 14:case 15:
				prev = n;
				a[i] = n;
				i++;
				break;
			case 16:
				var end = i + 3 + this.getBits(2);
				if(end > max) throw "Invalid data";
				while(i < end) {
					a[i] = prev;
					i++;
				}
				break;
			case 17:
				i += 3 + this.getBits(3);
				if(i > max) throw "Invalid data";
				break;
			case 18:
				i += 11 + this.getBits(7);
				if(i > max) throw "Invalid data";
				break;
			default:
				throw "Invalid data";
			}
		}
	}
	,applyHuffman: function(h) {
		return (function($this) {
			var $r;
			var $e = (h);
			switch( $e[1] ) {
			case 0:
				var n = $e[2];
				$r = n;
				break;
			case 1:
				var b = $e[3], a = $e[2];
				$r = $this.applyHuffman($this.getBit()?b:a);
				break;
			case 2:
				var tbl = $e[3], n = $e[2];
				$r = $this.applyHuffman(tbl[$this.getBits(n)]);
				break;
			}
			return $r;
		}(this));
	}
	,addDist: function(d,len) {
		this.addBytes(this.window.buffer,this.window.pos - d,len);
	}
	,addDistOne: function(n) {
		var c = this.window.getLastChar();
		var _g = 0;
		while(_g < n) {
			var i = _g++;
			this.addByte(c);
		}
	}
	,addByte: function(b) {
		this.window.addByte(b);
		this.output.b[this.outpos] = b & 255;
		this.needed--;
		this.outpos++;
	}
	,addBytes: function(b,p,len) {
		this.window.addBytes(b,p,len);
		this.output.blit(this.outpos,b,p,len);
		this.needed -= len;
		this.outpos += len;
	}
	,resetBits: function() {
		this.bits = 0;
		this.nbits = 0;
	}
	,getRevBits: function(n) {
		return n == 0?0:this.getBit()?1 << n - 1 | this.getRevBits(n - 1):this.getRevBits(n - 1);
	}
	,getBit: function() {
		if(this.nbits == 0) {
			this.nbits = 8;
			this.bits = this.input.readByte();
		}
		var b = (this.bits & 1) == 1;
		this.nbits--;
		this.bits >>= 1;
		return b;
	}
	,getBits: function(n) {
		while(this.nbits < n) {
			this.bits |= this.input.readByte() << this.nbits;
			this.nbits += 8;
		}
		var b = this.bits & (1 << n) - 1;
		this.nbits -= n;
		this.bits >>= n;
		return b;
	}
	,readBytes: function(b,pos,len) {
		this.needed = len;
		this.outpos = pos;
		this.output = b;
		if(len > 0) while(this.inflateLoop()) {
		}
		return len - this.needed;
	}
	,buildFixedHuffman: function() {
		if(haxe.zip.InflateImpl.FIXED_HUFFMAN != null) return haxe.zip.InflateImpl.FIXED_HUFFMAN;
		var a = new Array();
		var _g = 0;
		while(_g < 288) {
			var n = _g++;
			a.push(n <= 143?8:n <= 255?9:n <= 279?7:8);
		}
		haxe.zip.InflateImpl.FIXED_HUFFMAN = this.htools.make(a,0,288,10);
		return haxe.zip.InflateImpl.FIXED_HUFFMAN;
	}
	,__class__: haxe.zip.InflateImpl
}
var hxpixel = {}
hxpixel.bytes = {}
hxpixel.bytes.BitReader = function(bytes) {
	this.bytesData = bytes.b;
	this.length = bytes.length * 8;
	this.position = 0;
};
$hxClasses["hxpixel.bytes.BitReader"] = hxpixel.bytes.BitReader;
hxpixel.bytes.BitReader.__name__ = true;
hxpixel.bytes.BitReader.prototype = {
	generateMask: function(offset,length) {
		return 255 >> 8 - length << offset;
	}
	,readIntBits: function(numBits) {
		if(this.position + numBits > this.length) throw "OutOfRange";
		var value = 0;
		var readed = 0;
		while(readed < numBits) {
			var bytePositon = this.position / 8 | 0;
			var $byte = this.bytesData[bytePositon];
			var offset = this.position % 8;
			var rest = 8 - offset;
			rest = readed + rest < numBits?rest:numBits - readed;
			value += ($byte & this.generateMask(offset,rest)) >> offset << readed;
			this.position += rest;
			readed += rest;
		}
		return value;
	}
	,readBits: function(numBits) {
		var bits = [];
		var _g = 0;
		while(_g < numBits) {
			var i = _g++;
			bits.push(this.readBit());
		}
		return bits;
	}
	,readBit: function() {
		if(this.position + 1 > this.length) throw "OutOfRange";
		var bytePositon = this.position / 8 | 0;
		var $byte = this.bytesData[bytePositon];
		var offset = this.position % 8;
		this.position++;
		return ($byte & 1 << offset) != 0;
	}
	,bitsAvailable: function() {
		return this.length - this.position;
	}
	,__class__: hxpixel.bytes.BitReader
}
hxpixel.bytes.BitWriter = function() {
	this.bitArray = [];
};
$hxClasses["hxpixel.bytes.BitWriter"] = hxpixel.bytes.BitWriter;
hxpixel.bytes.BitWriter.__name__ = true;
hxpixel.bytes.BitWriter.prototype = {
	getBytes: function() {
		var bytesOutput = new haxe.io.BytesOutput();
		var numBytes = this.get_length() / 8 | 0;
		var _g = 0;
		while(_g < numBytes) {
			var i = _g++;
			var value = 0;
			var _g1 = 0;
			while(_g1 < 8) {
				var bitPos = _g1++;
				if(this.bitArray[i * 8 + bitPos]) value += 1 << bitPos;
			}
			bytesOutput.writeByte(value);
		}
		var rest = this.get_length() % 8;
		if(rest != 0) {
			var value = 0;
			var _g = 0;
			while(_g < 8) {
				var bitPos = _g++;
				if(this.bitArray[numBytes * 8 + bitPos]) value += 1 << bitPos;
			}
			bytesOutput.writeByte(value);
		}
		return bytesOutput.getBytes();
	}
	,writeIntBits: function(value,numBits) {
		var _g = 0;
		while(_g < numBits) {
			var i = _g++;
			this.writeBit((value >> i & 1) == 1);
		}
	}
	,writeBits: function(bits) {
		var _g1 = 0, _g = bits.length;
		while(_g1 < _g) {
			var i = _g1++;
			this.writeBit(bits[i]);
		}
	}
	,writeBit: function(bit) {
		this.bitArray.push(bit);
	}
	,get_length: function() {
		return this.bitArray.length;
	}
	,__class__: hxpixel.bytes.BitWriter
}
hxpixel.bytes._Bits = {}
hxpixel.bytes._Bits.Bits_Impl_ = function() { }
$hxClasses["hxpixel.bytes._Bits.Bits_Impl_"] = hxpixel.bytes._Bits.Bits_Impl_;
hxpixel.bytes._Bits.Bits_Impl_.__name__ = true;
hxpixel.bytes._Bits.Bits_Impl_.get_length = function(this1) {
	return this1.length;
}
hxpixel.bytes._Bits.Bits_Impl_._new = function() {
	return [];
}
hxpixel.bytes._Bits.Bits_Impl_.writeBit = function(this1,bit) {
	this1.push(bit);
}
hxpixel.bytes._Bits.Bits_Impl_.writeBits = function(this1,bits) {
	var _g1 = 0, _g = bits.length;
	while(_g1 < _g) {
		var i = _g1++;
		this1.push(bits[i]);
	}
}
hxpixel.bytes._Bits.Bits_Impl_.writeIntBits = function(this1,value,bitLength) {
	var _g = 0;
	while(_g < bitLength) {
		var i = _g++;
		this1.push((value >> i & 1) == 1);
	}
}
hxpixel.bytes._Bits.Bits_Impl_.getBytes = function(this1) {
	var bytesOutput = new haxe.io.BytesOutput();
	var numBytes = this1.length / 8 | 0;
	var _g = 0;
	while(_g < numBytes) {
		var i = _g++;
		var value = 0;
		var _g1 = 0;
		while(_g1 < 8) {
			var bitPos = _g1++;
			if(this1[i * 8 + bitPos]) value += 1 << bitPos;
		}
		bytesOutput.writeByte(value);
	}
	var rest = this1.length % 8;
	if(rest != 0) {
		var value = 0;
		var _g = 0;
		while(_g < 8) {
			var bitPos = _g++;
			if(this1[numBytes * 8 + bitPos]) value += 1 << bitPos;
		}
		bytesOutput.writeByte(value);
	}
	return bytesOutput.getBytes();
}
hxpixel.bytes._Bits.Bits_Impl_.copy = function(this1) {
	var bits = [];
	var _g1 = 0, _g = this1.length;
	while(_g1 < _g) {
		var i = _g1++;
		bits.push(this1[i]);
	}
	return bits;
}
hxpixel.bytes._Bits.Bits_Impl_.subBits = function(this1,position,length) {
	var bits = [];
	var _g = 0;
	while(_g < length) {
		var i = _g++;
		bits.push(this1[position + i]);
	}
	return bits;
}
hxpixel.bytes._Bits.Bits_Impl_.arrayAccess = function(this1,key) {
	return this1[key];
}
hxpixel.bytes._Bits.Bits_Impl_.toString = function(this1) {
	var str = "";
	var _g1 = 0, _g = this1.length;
	while(_g1 < _g) {
		var i = _g1++;
		str += this1[i]?"1":"0";
	}
	return str;
}
hxpixel.bytes._Bits.Bits_Impl_.add = function(a,b) {
	var bits = hxpixel.bytes._Bits.Bits_Impl_.copy(a);
	hxpixel.bytes._Bits.Bits_Impl_.writeBits(bits,b);
	return bits;
}
hxpixel.bytes._Bits.Bits_Impl_.marge = function(a,b) {
	var bits = [];
	var _g1 = 0, _g = a.length;
	while(_g1 < _g) {
		var i = _g1++;
		bits.push(a[i]);
	}
	var _g1 = 0, _g = b.length;
	while(_g1 < _g) {
		var i = _g1++;
		bits.push(b[i]);
	}
	return bits;
}
hxpixel.bytes._Bits.Bits_Impl_.fromIntBits = function(value,bitLength) {
	var bits = [];
	hxpixel.bytes._Bits.Bits_Impl_.writeIntBits(bits,value,bitLength);
	return bits;
}
hxpixel.bytes._Bits.Bits_Impl_.toInt = function(this1) {
	var value = 0;
	var _g1 = 0, _g = this1.length;
	while(_g1 < _g) {
		var i = _g1++;
		if(this1[i]) value += 1 << i;
	}
	return value;
}
hxpixel.bytes.Endian = $hxClasses["hxpixel.bytes.Endian"] = { __ename__ : true, __constructs__ : ["BigEndian","LittleEndian"] }
hxpixel.bytes.Endian.BigEndian = ["BigEndian",0];
hxpixel.bytes.Endian.BigEndian.toString = $estr;
hxpixel.bytes.Endian.BigEndian.__enum__ = hxpixel.bytes.Endian;
hxpixel.bytes.Endian.LittleEndian = ["LittleEndian",1];
hxpixel.bytes.Endian.LittleEndian.toString = $estr;
hxpixel.bytes.Endian.LittleEndian.__enum__ = hxpixel.bytes.Endian;
hxpixel.bytes.BytesInputWrapper = function(b,endian,pos,len) {
	haxe.io.BytesInput.call(this,b,pos,len);
	if(endian != null) {
		switch( (endian)[1] ) {
		case 0:
			this.set_bigEndian(true);
			break;
		case 1:
			this.set_bigEndian(false);
			break;
		}
	}
};
$hxClasses["hxpixel.bytes.BytesInputWrapper"] = hxpixel.bytes.BytesInputWrapper;
hxpixel.bytes.BytesInputWrapper.__name__ = true;
hxpixel.bytes.BytesInputWrapper.__super__ = haxe.io.BytesInput;
hxpixel.bytes.BytesInputWrapper.prototype = $extend(haxe.io.BytesInput.prototype,{
	getAbailable: function() {
		return this.b.length - this.pos;
	}
	,__class__: hxpixel.bytes.BytesInputWrapper
});
hxpixel.bytes.Inflater = function() { }
$hxClasses["hxpixel.bytes.Inflater"] = hxpixel.bytes.Inflater;
hxpixel.bytes.Inflater.__name__ = true;
hxpixel.bytes.Inflater.uncompress = function(bytes) {
	return haxe.zip.InflateImpl.run(new haxe.io.BytesInput(bytes));
}
hxpixel.images = {}
hxpixel.images.color = {}
hxpixel.images.color._Rgb = {}
hxpixel.images.color._Rgb.Rgb_Impl_ = function() { }
$hxClasses["hxpixel.images.color._Rgb.Rgb_Impl_"] = hxpixel.images.color._Rgb.Rgb_Impl_;
hxpixel.images.color._Rgb.Rgb_Impl_.__name__ = true;
hxpixel.images.color._Rgb.Rgb_Impl_._new = function(a) {
	return a & 16777215;
}
hxpixel.images.color._Rgb.Rgb_Impl_.get_red = function(this1) {
	return this1 >> 16 & 255;
}
hxpixel.images.color._Rgb.Rgb_Impl_.set_red = function(this1,red) {
	return this1 = (red & 255) << 16 | this1 & -16711681;
}
hxpixel.images.color._Rgb.Rgb_Impl_.get_green = function(this1) {
	return this1 >> 8 & 255;
}
hxpixel.images.color._Rgb.Rgb_Impl_.set_green = function(this1,green) {
	return this1 = (green & 255) << 8 | this1 & -65281;
}
hxpixel.images.color._Rgb.Rgb_Impl_.get_blue = function(this1) {
	return this1 & 255;
}
hxpixel.images.color._Rgb.Rgb_Impl_.set_blue = function(this1,blue) {
	return this1 = blue & 255 | this1 & -256;
}
hxpixel.images.color._Rgb.Rgb_Impl_.fromComponents = function(red,green,blue) {
	return (hxpixel.images.color._Rgb.Rgb_Impl_.limitateComponent(red) << 16 | hxpixel.images.color._Rgb.Rgb_Impl_.limitateComponent(green) << 8 | hxpixel.images.color._Rgb.Rgb_Impl_.limitateComponent(blue)) & 16777215;
}
hxpixel.images.color._Rgb.Rgb_Impl_.add = function(lhs,rhs) {
	var red = (lhs >> 16 & 255) + (rhs >> 16 & 255);
	var green = (lhs >> 8 & 255) + (rhs >> 8 & 255);
	var blue = (lhs & 255) + (rhs & 255);
	return hxpixel.images.color._Rgb.Rgb_Impl_.fromComponents(red,green,blue);
}
hxpixel.images.color._Rgb.Rgb_Impl_.sub = function(lhs,rhs) {
	var red = (lhs >> 16 & 255) - (rhs >> 16 & 255);
	var green = (lhs >> 8 & 255) - (rhs >> 8 & 255);
	var blue = (lhs & 255) - (rhs & 255);
	return hxpixel.images.color._Rgb.Rgb_Impl_.fromComponents(red,green,blue);
}
hxpixel.images.color._Rgb.Rgb_Impl_.fromRgba = function(rgba) {
	return rgba & 16777215;
}
hxpixel.images.color._Rgb.Rgb_Impl_.toRgba = function(this1) {
	this1 = -16777216 | this1 & 16777215;
	return this1;
}
hxpixel.images.color._Rgb.Rgb_Impl_.toInt = function(this1) {
	return this1 & 16777215;
}
hxpixel.images.color._Rgb.Rgb_Impl_.toString = function(this1) {
	return StringTools.hex(this1 & 16777215);
}
hxpixel.images.color._Rgb.Rgb_Impl_.limitateComponent = function(a) {
	return a > 255?255:a < 0?0:a;
}
hxpixel.images.color._Rgba = {}
hxpixel.images.color._Rgba.Rgba_Impl_ = function() { }
$hxClasses["hxpixel.images.color._Rgba.Rgba_Impl_"] = hxpixel.images.color._Rgba.Rgba_Impl_;
hxpixel.images.color._Rgba.Rgba_Impl_.__name__ = true;
hxpixel.images.color._Rgba.Rgba_Impl_._new = function(a) {
	return a;
}
hxpixel.images.color._Rgba.Rgba_Impl_.get_alpha = function(this1) {
	return this1 >> 24 & 255;
}
hxpixel.images.color._Rgba.Rgba_Impl_.set_alpha = function(this1,alpha) {
	return this1 = (alpha & 255) << 24 | this1 & 16777215;
}
hxpixel.images.color._Rgba.Rgba_Impl_.get_red = function(this1) {
	return this1 >> 16 & 255;
}
hxpixel.images.color._Rgba.Rgba_Impl_.set_red = function(this1,red) {
	return this1 = (red & 255) << 16 | this1 & -16711681;
}
hxpixel.images.color._Rgba.Rgba_Impl_.get_green = function(this1) {
	return this1 >> 8 & 255;
}
hxpixel.images.color._Rgba.Rgba_Impl_.set_green = function(this1,green) {
	return this1 = (green & 255) << 8 | this1 & -65281;
}
hxpixel.images.color._Rgba.Rgba_Impl_.get_blue = function(this1) {
	return this1 & 255;
}
hxpixel.images.color._Rgba.Rgba_Impl_.set_blue = function(this1,blue) {
	return this1 = blue & 255 | this1 & -256;
}
hxpixel.images.color._Rgba.Rgba_Impl_.fromComponents = function(red,green,blue,alpha) {
	if(alpha == null) alpha = 255;
	return hxpixel.images.color._Rgba.Rgba_Impl_.limitateComponent(alpha) << 24 | hxpixel.images.color._Rgba.Rgba_Impl_.limitateComponent(red) << 16 | hxpixel.images.color._Rgba.Rgba_Impl_.limitateComponent(green) << 8 | hxpixel.images.color._Rgba.Rgba_Impl_.limitateComponent(blue);
}
hxpixel.images.color._Rgba.Rgba_Impl_.add = function(lhs,rhs) {
	var alpha = (lhs >> 24 & 255) + (rhs >> 24 & 255);
	var red = (lhs >> 16 & 255) + (rhs >> 16 & 255);
	var green = (lhs >> 8 & 255) + (rhs >> 8 & 255);
	var blue = (lhs & 255) + (rhs & 255);
	return hxpixel.images.color._Rgba.Rgba_Impl_.fromComponents(red,green,blue,alpha);
}
hxpixel.images.color._Rgba.Rgba_Impl_.sub = function(lhs,rhs) {
	var alpha = (lhs >> 24 & 255) - (rhs >> 24 & 255);
	var red = (lhs >> 16 & 255) - (rhs >> 16 & 255);
	var green = (lhs >> 8 & 255) - (rhs >> 8 & 255);
	var blue = (lhs & 255) - (rhs & 255);
	return hxpixel.images.color._Rgba.Rgba_Impl_.fromComponents(red,green,blue,alpha);
}
hxpixel.images.color._Rgba.Rgba_Impl_.toString = function(this1) {
	return StringTools.hex(this1);
}
hxpixel.images.color._Rgba.Rgba_Impl_.limitateComponent = function(a) {
	return a > 255?255:a < 0?0:a;
}
hxpixel.images.gif = {}
hxpixel.images.gif.Error = $hxClasses["hxpixel.images.gif.Error"] = { __ename__ : true, __constructs__ : ["InvalidFormat","UnsupportedFormat"] }
hxpixel.images.gif.Error.InvalidFormat = ["InvalidFormat",0];
hxpixel.images.gif.Error.InvalidFormat.toString = $estr;
hxpixel.images.gif.Error.InvalidFormat.__enum__ = hxpixel.images.gif.Error;
hxpixel.images.gif.Error.UnsupportedFormat = ["UnsupportedFormat",1];
hxpixel.images.gif.Error.UnsupportedFormat.toString = $estr;
hxpixel.images.gif.Error.UnsupportedFormat.__enum__ = hxpixel.images.gif.Error;
hxpixel.images.gif.GifDecoder = function() { }
$hxClasses["hxpixel.images.gif.GifDecoder"] = hxpixel.images.gif.GifDecoder;
hxpixel.images.gif.GifDecoder.__name__ = true;
hxpixel.images.gif.GifDecoder.decode = function(bytes) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.LittleEndian);
	var gifInfo = new hxpixel.images.gif.GifInfo();
	hxpixel.images.gif.GifDecoder.readHeader(bytesInput,gifInfo);
	if(gifInfo.globalColorTableFlag) hxpixel.images.gif.GifDecoder.readGlobalColorTable(bytesInput,gifInfo);
	var gifFrameInfo = new hxpixel.images.gif.GifFrameInfo(gifInfo);
	while(true) {
		var signature = bytesInput.readByte();
		if(signature == 33) {
			var label = bytesInput.readByte();
			if(label == 249) hxpixel.images.gif.GifDecoder.readGraphicControlExtension(bytesInput,gifFrameInfo); else break;
		} else if(signature == 44) {
			hxpixel.images.gif.GifDecoder.readImageDescriptor(bytesInput,gifFrameInfo);
			if(gifFrameInfo.localColorTableFlag) hxpixel.images.gif.GifDecoder.readLocalColorTable(bytesInput,gifFrameInfo);
			hxpixel.images.gif.GifDecoder.readImageData(bytesInput,gifFrameInfo);
			gifInfo.frameList.push(gifFrameInfo);
			gifFrameInfo = new hxpixel.images.gif.GifFrameInfo(gifInfo);
		} else if(signature == 59) break; else throw hxpixel.images.gif.Error.InvalidFormat;
	}
	return gifInfo;
}
hxpixel.images.gif.GifDecoder.readHeader = function(input,gifInfo) {
	hxpixel.images.gif.GifDecoder.validateSignature(input.read(3));
	hxpixel.images.gif.GifDecoder.readVersion(input.read(3),gifInfo);
	gifInfo.logicalScreenWidth = input.readInt16();
	gifInfo.logicalScreenHeight = input.readInt16();
	var packedFields = input.readByte();
	gifInfo.globalColorTableFlag = (packedFields & 128) == 128;
	gifInfo.colorResolution = (packedFields & 112) >> 4;
	gifInfo.sortFlag = (packedFields & 8) == 8;
	gifInfo.sizeOfGlobalTable = packedFields & 7;
	gifInfo.backgroundColorIndex = input.readByte();
	gifInfo.pixelAspectRaito = input.readByte();
}
hxpixel.images.gif.GifDecoder.validateSignature = function(bytes) {
	if(bytes.toString() != "GIF") throw hxpixel.images.gif.Error.InvalidFormat;
}
hxpixel.images.gif.GifDecoder.readVersion = function(bytes,gifInfo) {
	var _g = bytes.toString();
	switch(_g) {
	case "87a":
		gifInfo.version = hxpixel.images.gif.Version.Gif87a;
		throw hxpixel.images.gif.Error.UnsupportedFormat;
		break;
	case "89a":
		gifInfo.version = hxpixel.images.gif.Version.Gif89a;
		break;
	default:
		throw hxpixel.images.gif.Error.InvalidFormat;
	}
}
hxpixel.images.gif.GifDecoder.readGlobalColorTable = function(input,gifInfo) {
	var tableLength = 1 << gifInfo.sizeOfGlobalTable + 1;
	var _g = 0;
	while(_g < tableLength) {
		var i = _g++;
		gifInfo.globalColorTable.push(hxpixel.images.gif.GifDecoder.readRgb(input));
	}
}
hxpixel.images.gif.GifDecoder.readGraphicControlExtension = function(input,gifFrameInfo) {
	var blockSize = input.readByte();
	if(blockSize != 4) throw hxpixel.images.gif.Error.InvalidFormat;
	var packedFields = input.readByte();
	gifFrameInfo.disposalMothod = (packedFields & 28) >> 2;
	gifFrameInfo.userInputFlag = (packedFields & 2) == 2;
	gifFrameInfo.transparentColorFlag = (packedFields & 1) == 1;
	gifFrameInfo.delayTime = input.readInt16();
	gifFrameInfo.transparentColorIndex = input.readByte();
	var terminator = input.readByte();
	if(terminator != 0) throw hxpixel.images.gif.Error.InvalidFormat;
}
hxpixel.images.gif.GifDecoder.readImageDescriptor = function(input,gifFrameInfo) {
	gifFrameInfo.imageLeftPosition = input.readInt16();
	gifFrameInfo.imageTopPosition = input.readInt16();
	gifFrameInfo.imageWidth = input.readInt16();
	gifFrameInfo.imageHeight = input.readInt16();
	var packedFields = input.readByte();
	gifFrameInfo.localColorTableFlag = (packedFields & 128) == 128;
	gifFrameInfo.interlaceFlag = (packedFields & 64) == 64;
	gifFrameInfo.sortFlag = (packedFields & 32) == 32;
	gifFrameInfo.sizeOfLocalColorTable = packedFields & 7;
}
hxpixel.images.gif.GifDecoder.readLocalColorTable = function(input,gifFrameInfo) {
	var tableLength = 1 << gifFrameInfo.sizeOfLocalColorTable + 1;
	var _g = 0;
	while(_g < tableLength) {
		var i = _g++;
		gifFrameInfo.localColorTable.push(hxpixel.images.gif.GifDecoder.readRgb(input));
	}
}
hxpixel.images.gif.GifDecoder.readImageData = function(input,gifFrameInfo) {
	var lzwMinimumCodeSize = input.readByte();
	console.log("lzwMinimumCodeSize: " + lzwMinimumCodeSize);
	var joinOutput = new haxe.io.BytesOutput();
	while(true) {
		var blockSize = input.readByte();
		console.log("blockSize: " + blockSize);
		if(blockSize == 0) break;
		var bytes = input.read(blockSize);
		joinOutput.writeBytes(bytes,0,bytes.length);
	}
	var joinBytes = joinOutput.getBytes();
	var bitReader = new hxpixel.bytes.BitReader(joinBytes);
	var bitDepth = gifFrameInfo.parent.colorResolution + 1;
	var codeLength = lzwMinimumCodeSize + 1;
	var clearCode = 1 << lzwMinimumCodeSize;
	var endCode = clearCode + 1;
	var registerNum = endCode + 1;
	var dictionary = new haxe.ds.IntMap();
	var _g = 0;
	while(_g < clearCode) {
		var i = _g++;
		var v = hxpixel.bytes._Bits.Bits_Impl_.fromIntBits(i,lzwMinimumCodeSize);
		dictionary.set(i,v);
		v;
	}
	var bitWriter = new hxpixel.bytes.BitWriter();
	var pixelNum = gifFrameInfo.imageWidth * gifFrameInfo.imageHeight;
	var firstCode = bitReader.readBits(codeLength);
	var prefix;
	if(hxpixel.bytes._Bits.Bits_Impl_.toInt(firstCode) == clearCode) prefix = hxpixel.bytes._Bits.Bits_Impl_.subBits(bitReader.readBits(codeLength),0,bitDepth); else prefix = hxpixel.bytes._Bits.Bits_Impl_.subBits(firstCode,0,bitDepth);
	var suffix = hxpixel.bytes._Bits.Bits_Impl_.copy(prefix);
	var readedPixel = 0;
	while(readedPixel < pixelNum) {
		var code = bitReader.readIntBits(codeLength);
		if(!dictionary.exists(code)) {
			bitWriter.writeBits(prefix);
			suffix = hxpixel.bytes._Bits.Bits_Impl_.add(hxpixel.bytes._Bits.Bits_Impl_.subBits(prefix,0,bitDepth),suffix);
			dictionary.set(registerNum,suffix);
			suffix;
			registerNum++;
			if(registerNum >= 1 << codeLength) codeLength++;
			prefix = hxpixel.bytes._Bits.Bits_Impl_.copy(suffix);
		} else {
			bitWriter.writeBits(prefix);
			suffix = dictionary.get(code);
			var v = hxpixel.bytes._Bits.Bits_Impl_.add(prefix,hxpixel.bytes._Bits.Bits_Impl_.subBits(suffix,0,bitDepth));
			dictionary.set(registerNum,v);
			v;
			registerNum++;
			if(registerNum >= 1 << codeLength) codeLength++;
			prefix = hxpixel.bytes._Bits.Bits_Impl_.copy(suffix);
		}
		readedPixel = bitWriter.get_length() / bitDepth | 0;
	}
	bitWriter.writeBits(prefix);
	var bytes = bitWriter.getBytes();
	var bitReader2 = new hxpixel.bytes.BitReader(bytes);
	var _g = 0;
	while(_g < pixelNum) {
		var i = _g++;
		gifFrameInfo.imageData[i] = bitReader2.readIntBits(bitDepth);
	}
}
hxpixel.images.gif.GifDecoder.readRgb = function(input) {
	var red = input.readByte();
	var green = input.readByte();
	var blue = input.readByte();
	return hxpixel.images.color._Rgb.Rgb_Impl_.fromComponents(red,green,blue);
}
hxpixel.images.gif.GifFrameInfo = function(parent) {
	this.parent = parent;
	this.localColorTable = [];
	this.imageData = [];
};
$hxClasses["hxpixel.images.gif.GifFrameInfo"] = hxpixel.images.gif.GifFrameInfo;
hxpixel.images.gif.GifFrameInfo.__name__ = true;
hxpixel.images.gif.GifFrameInfo.prototype = {
	getRgbaImageData: function() {
		var rgbaPalette = this.parent.globalColorTable;
		var rgbaImageData = new Array();
		var _g1 = 0, _g = this.imageData.length;
		while(_g1 < _g) {
			var i = _g1++;
			rgbaImageData[i] = (function($this) {
				var $r;
				var this1 = rgbaPalette[$this.imageData[i]];
				this1 = -16777216 | this1 & 16777215;
				$r = this1;
				return $r;
			}(this));
		}
		return rgbaImageData;
	}
	,__class__: hxpixel.images.gif.GifFrameInfo
}
hxpixel.images.gif.Version = $hxClasses["hxpixel.images.gif.Version"] = { __ename__ : true, __constructs__ : ["Gif87a","Gif89a"] }
hxpixel.images.gif.Version.Gif87a = ["Gif87a",0];
hxpixel.images.gif.Version.Gif87a.toString = $estr;
hxpixel.images.gif.Version.Gif87a.__enum__ = hxpixel.images.gif.Version;
hxpixel.images.gif.Version.Gif89a = ["Gif89a",1];
hxpixel.images.gif.Version.Gif89a.toString = $estr;
hxpixel.images.gif.Version.Gif89a.__enum__ = hxpixel.images.gif.Version;
hxpixel.images.gif.GifInfo = function() {
	this.globalColorTable = [];
	this.frameList = [];
};
$hxClasses["hxpixel.images.gif.GifInfo"] = hxpixel.images.gif.GifInfo;
hxpixel.images.gif.GifInfo.__name__ = true;
hxpixel.images.gif.GifInfo.prototype = {
	get_numFrames: function() {
		return this.frameList.length;
	}
	,__class__: hxpixel.images.gif.GifInfo
}
hxpixel.images.png = {}
hxpixel.images.png.ChunkType = $hxClasses["hxpixel.images.png.ChunkType"] = { __ename__ : true, __constructs__ : ["IHDR","sBIT","PLTE","IDAT","tRNS","bKGD","IEND"] }
hxpixel.images.png.ChunkType.IHDR = ["IHDR",0];
hxpixel.images.png.ChunkType.IHDR.toString = $estr;
hxpixel.images.png.ChunkType.IHDR.__enum__ = hxpixel.images.png.ChunkType;
hxpixel.images.png.ChunkType.sBIT = ["sBIT",1];
hxpixel.images.png.ChunkType.sBIT.toString = $estr;
hxpixel.images.png.ChunkType.sBIT.__enum__ = hxpixel.images.png.ChunkType;
hxpixel.images.png.ChunkType.PLTE = ["PLTE",2];
hxpixel.images.png.ChunkType.PLTE.toString = $estr;
hxpixel.images.png.ChunkType.PLTE.__enum__ = hxpixel.images.png.ChunkType;
hxpixel.images.png.ChunkType.IDAT = ["IDAT",3];
hxpixel.images.png.ChunkType.IDAT.toString = $estr;
hxpixel.images.png.ChunkType.IDAT.__enum__ = hxpixel.images.png.ChunkType;
hxpixel.images.png.ChunkType.tRNS = ["tRNS",4];
hxpixel.images.png.ChunkType.tRNS.toString = $estr;
hxpixel.images.png.ChunkType.tRNS.__enum__ = hxpixel.images.png.ChunkType;
hxpixel.images.png.ChunkType.bKGD = ["bKGD",5];
hxpixel.images.png.ChunkType.bKGD.toString = $estr;
hxpixel.images.png.ChunkType.bKGD.__enum__ = hxpixel.images.png.ChunkType;
hxpixel.images.png.ChunkType.IEND = ["IEND",6];
hxpixel.images.png.ChunkType.IEND.toString = $estr;
hxpixel.images.png.ChunkType.IEND.__enum__ = hxpixel.images.png.ChunkType;
hxpixel.images.png.Error = $hxClasses["hxpixel.images.png.Error"] = { __ename__ : true, __constructs__ : ["InvalidFormat","UnsupportedFormat"] }
hxpixel.images.png.Error.InvalidFormat = ["InvalidFormat",0];
hxpixel.images.png.Error.InvalidFormat.toString = $estr;
hxpixel.images.png.Error.InvalidFormat.__enum__ = hxpixel.images.png.Error;
hxpixel.images.png.Error.UnsupportedFormat = ["UnsupportedFormat",1];
hxpixel.images.png.Error.UnsupportedFormat.toString = $estr;
hxpixel.images.png.Error.UnsupportedFormat.__enum__ = hxpixel.images.png.Error;
hxpixel.images.png.PngDecoder = function() { }
$hxClasses["hxpixel.images.png.PngDecoder"] = hxpixel.images.png.PngDecoder;
hxpixel.images.png.PngDecoder.__name__ = true;
hxpixel.images.png.PngDecoder.decode = function(bytes) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.BigEndian);
	hxpixel.images.png.PngDecoder.validateSignature(bytesInput.read(8));
	var pngInfo = new hxpixel.images.png.PngInfo();
	var idatBuffer = new haxe.io.BytesOutput();
	while(bytesInput.getAbailable() > 12) {
		var chunkLength = bytesInput.readInt32();
		var chunkTypeString = bytesInput.readString(4);
		var chunkData = bytesInput.read(chunkLength);
		var crc = bytesInput.readInt32();
		var chunkType;
		try {
			chunkType = Type.createEnum(hxpixel.images.png.ChunkType,chunkTypeString);
		} catch( e ) {
			if( js.Boot.__instanceof(e,String) ) {
				continue;
			} else throw(e);
		}
		switch( (chunkType)[1] ) {
		case 0:
			hxpixel.images.png.PngDecoder.decodeHeader(chunkData,pngInfo);
			break;
		case 2:
			hxpixel.images.png.PngDecoder.decodePalette(chunkData,pngInfo);
			break;
		case 3:
			idatBuffer.writeBytes(chunkData,0,chunkData.length);
			break;
		case 4:
			hxpixel.images.png.PngDecoder.decodeTransparent(chunkData,pngInfo);
			break;
		case 5:
			hxpixel.images.png.PngDecoder.decodeBackground(chunkData,pngInfo);
			break;
		default:
			continue;
		}
	}
	hxpixel.images.png.PngDecoder.decodeImage(idatBuffer.getBytes(),pngInfo);
	return pngInfo;
}
hxpixel.images.png.PngDecoder.validateSignature = function(signatureBytes) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(signatureBytes,hxpixel.bytes.Endian.BigEndian);
	if(bytesInput.readInt32() != -1991225785 || bytesInput.readInt32() != 218765834) throw hxpixel.images.png.Error.InvalidFormat;
}
hxpixel.images.png.PngDecoder.decodeHeader = function(bytes,pngInfo) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.BigEndian);
	pngInfo.width = bytesInput.readInt32();
	pngInfo.height = bytesInput.readInt32();
	pngInfo.bitDepth = bytesInput.readInt8();
	pngInfo.colotType = (function($this) {
		var $r;
		var _g = bytesInput.readByte();
		$r = (function($this) {
			var $r;
			switch(_g) {
			case 0:
				$r = (function($this) {
					var $r;
					throw hxpixel.images.png.Error.UnsupportedFormat;
					return $r;
				}($this));
				break;
			case 2:
				$r = hxpixel.images.png.ColorType.TrueColor;
				break;
			case 3:
				$r = hxpixel.images.png.ColorType.IndexedColor;
				break;
			case 4:
				$r = (function($this) {
					var $r;
					throw hxpixel.images.png.Error.UnsupportedFormat;
					return $r;
				}($this));
				break;
			case 5:
				$r = (function($this) {
					var $r;
					throw hxpixel.images.png.Error.UnsupportedFormat;
					return $r;
				}($this));
				break;
			default:
				$r = (function($this) {
					var $r;
					throw hxpixel.images.png.Error.InvalidFormat;
					return $r;
				}($this));
			}
			return $r;
		}($this));
		return $r;
	}(this));
	pngInfo.compressionMethod = (function($this) {
		var $r;
		var _g1 = bytesInput.readByte();
		$r = (function($this) {
			var $r;
			switch(_g1) {
			case 0:
				$r = hxpixel.images.png.CompressionMethod.Deflate;
				break;
			default:
				$r = (function($this) {
					var $r;
					throw hxpixel.images.png.Error.InvalidFormat;
					return $r;
				}($this));
			}
			return $r;
		}($this));
		return $r;
	}(this));
	pngInfo.filterMethod = hxpixel.images.png.PngDecoder.readFilterMethod(bytesInput);
	pngInfo.interlaceMethod = (function($this) {
		var $r;
		var _g2 = bytesInput.readByte();
		$r = (function($this) {
			var $r;
			switch(_g2) {
			case 0:
				$r = hxpixel.images.png.InterlaceMethod.None;
				break;
			case 1:
				$r = (function($this) {
					var $r;
					throw hxpixel.images.png.Error.UnsupportedFormat;
					return $r;
				}($this));
				break;
			default:
				$r = (function($this) {
					var $r;
					throw hxpixel.images.png.Error.InvalidFormat;
					return $r;
				}($this));
			}
			return $r;
		}($this));
		return $r;
	}(this));
}
hxpixel.images.png.PngDecoder.readFilterMethod = function(input) {
	return (function($this) {
		var $r;
		var _g = input.readByte();
		$r = (function($this) {
			var $r;
			switch(_g) {
			case 0:
				$r = hxpixel.images.png.FilterMethod.None;
				break;
			case 1:
				$r = hxpixel.images.png.FilterMethod.Sub;
				break;
			case 2:
				$r = hxpixel.images.png.FilterMethod.Up;
				break;
			case 3:
				$r = hxpixel.images.png.FilterMethod.Average;
				break;
			case 4:
				$r = hxpixel.images.png.FilterMethod.Peath;
				break;
			default:
				$r = (function($this) {
					var $r;
					throw hxpixel.images.png.Error.InvalidFormat;
					return $r;
				}($this));
			}
			return $r;
		}($this));
		return $r;
	}(this));
}
hxpixel.images.png.PngDecoder.decodePalette = function(bytes,pngInfo) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.BigEndian);
	pngInfo.palette = [];
	var index = 0;
	while(bytesInput.getAbailable() >= 3) {
		pngInfo.palette[index] = hxpixel.images.png.PngDecoder.readRgb(bytesInput);
		++index;
	}
}
hxpixel.images.png.PngDecoder.decodeImage = function(bytes,pngInfo) {
	var uncompressed = hxpixel.bytes.Inflater.uncompress(bytes);
	switch( (pngInfo.colotType)[1] ) {
	case 1:
		hxpixel.images.png.PngDecoder.decodeRgbImage(uncompressed,pngInfo);
		break;
	case 2:
		hxpixel.images.png.PngDecoder.decodeIndexedImage(uncompressed,pngInfo);
		break;
	default:
		throw hxpixel.images.png.Error.UnsupportedFormat;
	}
}
hxpixel.images.png.PngDecoder.decodeRgbImage = function(bytes,pngInfo) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.BigEndian);
	var position = 0;
	pngInfo.imageData = [];
	var _g1 = 0, _g = pngInfo.height;
	while(_g1 < _g) {
		var y = _g1++;
		var filterMethod = hxpixel.images.png.PngDecoder.readFilterMethod(bytesInput);
		var reverseFilter = hxpixel.images.png.PngDecoder.selectReverseFilter(filterMethod);
		var _g3 = 0, _g2 = pngInfo.width;
		while(_g3 < _g2) {
			var x = _g3++;
			var color = hxpixel.images.png.PngDecoder.readRgb(bytesInput);
			var reconColor = ((function(f,x1,y1,a1,a2) {
				return function() {
					return f(x1,y1,a1,a2);
				};
			})(reverseFilter,x,y,color,pngInfo))();
			pngInfo.imageData[position] = -16777216 + reconColor;
			++position;
		}
	}
}
hxpixel.images.png.PngDecoder.selectReverseFilter = function(filterMethod) {
	return (function($this) {
		var $r;
		switch( (filterMethod)[1] ) {
		case 0:
			$r = hxpixel.images.png.PngDecoder.applyReverseFilterNone;
			break;
		case 1:
			$r = hxpixel.images.png.PngDecoder.applyReverseFilterSub;
			break;
		case 2:
			$r = hxpixel.images.png.PngDecoder.applyReverseFilterUp;
			break;
		case 3:
			$r = hxpixel.images.png.PngDecoder.applyReverseFilterAverage;
			break;
		case 4:
			$r = hxpixel.images.png.PngDecoder.applyReverseFilterPaeth;
			break;
		}
		return $r;
	}(this));
}
hxpixel.images.png.PngDecoder.applyReverseFilterNone = function(x,y,color,pngInfo) {
	return color;
}
hxpixel.images.png.PngDecoder.applyReverseFilterSub = function(x,y,color,pngInfo) {
	var leftColor = hxpixel.images.png.PngDecoder.seekScanLine(x - 1,y,pngInfo);
	return hxpixel.images.png.PngDecoder.margeColor(color,leftColor);
}
hxpixel.images.png.PngDecoder.applyReverseFilterUp = function(x,y,color,pngInfo) {
	var aboveColor = hxpixel.images.png.PngDecoder.seekScanLine(x,y - 1,pngInfo);
	return hxpixel.images.png.PngDecoder.margeColor(color,aboveColor);
}
hxpixel.images.png.PngDecoder.applyReverseFilterAverage = function(x,y,color,pngInfo) {
	var leftColor = hxpixel.images.png.PngDecoder.seekScanLine(x - 1,y,pngInfo);
	var aboveColor = hxpixel.images.png.PngDecoder.seekScanLine(x,y - 1,pngInfo);
	return hxpixel.images.png.PngDecoder.margeColor(color,hxpixel.images.png.PngDecoder.margeColor(leftColor,aboveColor) / 2 | 0);
}
hxpixel.images.png.PngDecoder.applyReverseFilterPaeth = function(x,y,color,pngInfo) {
	var leftColor = hxpixel.images.png.PngDecoder.seekScanLine(x - 1,y,pngInfo);
	var aboveColor = hxpixel.images.png.PngDecoder.seekScanLine(x,y - 1,pngInfo);
	var upperLeftColor = hxpixel.images.png.PngDecoder.seekScanLine(x - 1,y - 1,pngInfo);
	var byteNum = 3;
	var paethColor = 0;
	var _g = 0;
	while(_g < byteNum) {
		var i = _g++;
		var shiftNum = i * 8;
		var mask = 255 << shiftNum;
		var maskedLeft = (leftColor & mask) >> shiftNum;
		var maskedAbove = (aboveColor & mask) >> shiftNum;
		var maskedUpperLeft = (upperLeftColor & mask) >> shiftNum;
		paethColor += hxpixel.images.png.PngDecoder.applyPaethPredictor(maskedLeft,maskedAbove,maskedUpperLeft) << shiftNum;
	}
	return hxpixel.images.png.PngDecoder.margeColor(color,paethColor);
}
hxpixel.images.png.PngDecoder.seekScanLine = function(x,y,pngInfo) {
	if(x < 0 || y < 0) return 0;
	return pngInfo.imageData[y * pngInfo.width + x] & 16777215;
}
hxpixel.images.png.PngDecoder.margeColor = function(a,b) {
	var red = (a & 16711680) + (b & 16711680) & 16711680;
	var green = (a & 65280) + (b & 65280) & 65280;
	var blue = (a & 255) + (b & 255) & 255;
	return red + green + blue;
}
hxpixel.images.png.PngDecoder.applyPaethPredictor = function(left,above,upperLeft) {
	var distance = function(a,b) {
		return a < b?b - a:a - b;
	};
	var p = left + above - upperLeft;
	var pLeft = ((function(f,a1,b1) {
		return function() {
			return f(a1,b1);
		};
	})(distance,p,left))();
	var pAbove = ((function(f1,a2,b2) {
		return function() {
			return f1(a2,b2);
		};
	})(distance,p,above))();
	var pUpperLeft = ((function(f2,a3,b3) {
		return function() {
			return f2(a3,b3);
		};
	})(distance,p,upperLeft))();
	if(pLeft <= pAbove && pLeft <= pUpperLeft) return left; else if(pAbove <= pUpperLeft) return above; else return upperLeft;
}
hxpixel.images.png.PngDecoder.decodeIndexedImage = function(bytes,pngInfo) {
	pngInfo.imageData = [];
	if(pngInfo.bitDepth == 8) hxpixel.images.png.PngDecoder.decodeByteIndexedImage(bytes,pngInfo); else hxpixel.images.png.PngDecoder.decodeBitIndexedImage(bytes,pngInfo);
}
hxpixel.images.png.PngDecoder.decodeByteIndexedImage = function(bytes,pngInfo) {
	var pixelIndex = 0;
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.BigEndian);
	var _g1 = 0, _g = pngInfo.height;
	while(_g1 < _g) {
		var y = _g1++;
		bytesInput.readByte();
		var _g3 = 0, _g2 = pngInfo.width;
		while(_g3 < _g2) {
			var x = _g3++;
			var paletteIndex = bytesInput.readByte();
			pngInfo.imageData[pixelIndex] = paletteIndex;
			++pixelIndex;
		}
	}
}
hxpixel.images.png.PngDecoder.decodeBitIndexedImage = function(bytes,pngInfo) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.BigEndian);
	var n = bytes.length;
	var bitDepth = pngInfo.bitDepth;
	var mask = (1 << bitDepth) - 1;
	bytesInput.readByte();
	var x = 0;
	var y = 0;
	var width = pngInfo.width;
	var height = pngInfo.height;
	var value = 0;
	var bitPosition = 0;
	var pixelIndex = 0;
	while(bytesInput.getAbailable() > 0 && y < height) {
		value <<= bitPosition;
		value += bytesInput.readByte();
		bitPosition += 8;
		while(bitPosition >= bitDepth) {
			var shiftMask = mask << bitPosition - bitDepth;
			var paletteIndex = (value & shiftMask) >> bitPosition - bitDepth;
			value &= ~shiftMask;
			bitPosition -= bitDepth;
			pngInfo.imageData[pixelIndex] = paletteIndex;
			++pixelIndex;
			++x;
			if(x >= width) {
				x = 0;
				++y;
				if(bytesInput.getAbailable() > 0 && y < height) bytesInput.readByte();
			}
		}
	}
}
hxpixel.images.png.PngDecoder.decodeTransparent = function(bytes,pngInfo) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.BigEndian);
	switch( (pngInfo.colotType)[1] ) {
	case 0:
		pngInfo.transparent = bytesInput.readInt16();
		break;
	case 1:
		pngInfo.transparent = hxpixel.images.png.PngDecoder.readRgb(bytesInput);
		break;
	case 2:
		pngInfo.paletteTransparent = hxpixel.images.png.PngDecoder.readBytesArray(bytesInput);
		break;
	default:
		throw hxpixel.images.png.Error.InvalidFormat;
	}
}
hxpixel.images.png.PngDecoder.decodeBackground = function(bytes,pngInfo) {
	var bytesInput = new hxpixel.bytes.BytesInputWrapper(bytes,hxpixel.bytes.Endian.BigEndian);
	switch( (pngInfo.colotType)[1] ) {
	case 2:
		pngInfo.background = bytesInput.readByte();
		break;
	case 0:
	case 3:
		pngInfo.background = bytesInput.readInt16();
		break;
	case 1:
	case 4:
		pngInfo.background = hxpixel.images.png.PngDecoder.readRgb(bytesInput);
		break;
	}
	pngInfo.existBackground = true;
}
hxpixel.images.png.PngDecoder.readRgb = function(input) {
	var red = input.readByte();
	var green = input.readByte();
	var blue = input.readByte();
	return (red << 16) + (green << 8) + blue;
}
hxpixel.images.png.PngDecoder.readBytesArray = function(bytesInput) {
	var bytesArray = new Array();
	while(bytesInput.getAbailable() > 0) bytesArray.push(bytesInput.readByte());
	return bytesArray;
}
hxpixel.images.png.ColorType = $hxClasses["hxpixel.images.png.ColorType"] = { __ename__ : true, __constructs__ : ["GreyScale","TrueColor","IndexedColor","GreyScaleWithAlpha","TrueColorWithAlpha"] }
hxpixel.images.png.ColorType.GreyScale = ["GreyScale",0];
hxpixel.images.png.ColorType.GreyScale.toString = $estr;
hxpixel.images.png.ColorType.GreyScale.__enum__ = hxpixel.images.png.ColorType;
hxpixel.images.png.ColorType.TrueColor = ["TrueColor",1];
hxpixel.images.png.ColorType.TrueColor.toString = $estr;
hxpixel.images.png.ColorType.TrueColor.__enum__ = hxpixel.images.png.ColorType;
hxpixel.images.png.ColorType.IndexedColor = ["IndexedColor",2];
hxpixel.images.png.ColorType.IndexedColor.toString = $estr;
hxpixel.images.png.ColorType.IndexedColor.__enum__ = hxpixel.images.png.ColorType;
hxpixel.images.png.ColorType.GreyScaleWithAlpha = ["GreyScaleWithAlpha",3];
hxpixel.images.png.ColorType.GreyScaleWithAlpha.toString = $estr;
hxpixel.images.png.ColorType.GreyScaleWithAlpha.__enum__ = hxpixel.images.png.ColorType;
hxpixel.images.png.ColorType.TrueColorWithAlpha = ["TrueColorWithAlpha",4];
hxpixel.images.png.ColorType.TrueColorWithAlpha.toString = $estr;
hxpixel.images.png.ColorType.TrueColorWithAlpha.__enum__ = hxpixel.images.png.ColorType;
hxpixel.images.png.CompressionMethod = $hxClasses["hxpixel.images.png.CompressionMethod"] = { __ename__ : true, __constructs__ : ["Deflate"] }
hxpixel.images.png.CompressionMethod.Deflate = ["Deflate",0];
hxpixel.images.png.CompressionMethod.Deflate.toString = $estr;
hxpixel.images.png.CompressionMethod.Deflate.__enum__ = hxpixel.images.png.CompressionMethod;
hxpixel.images.png.FilterMethod = $hxClasses["hxpixel.images.png.FilterMethod"] = { __ename__ : true, __constructs__ : ["None","Sub","Up","Average","Peath"] }
hxpixel.images.png.FilterMethod.None = ["None",0];
hxpixel.images.png.FilterMethod.None.toString = $estr;
hxpixel.images.png.FilterMethod.None.__enum__ = hxpixel.images.png.FilterMethod;
hxpixel.images.png.FilterMethod.Sub = ["Sub",1];
hxpixel.images.png.FilterMethod.Sub.toString = $estr;
hxpixel.images.png.FilterMethod.Sub.__enum__ = hxpixel.images.png.FilterMethod;
hxpixel.images.png.FilterMethod.Up = ["Up",2];
hxpixel.images.png.FilterMethod.Up.toString = $estr;
hxpixel.images.png.FilterMethod.Up.__enum__ = hxpixel.images.png.FilterMethod;
hxpixel.images.png.FilterMethod.Average = ["Average",3];
hxpixel.images.png.FilterMethod.Average.toString = $estr;
hxpixel.images.png.FilterMethod.Average.__enum__ = hxpixel.images.png.FilterMethod;
hxpixel.images.png.FilterMethod.Peath = ["Peath",4];
hxpixel.images.png.FilterMethod.Peath.toString = $estr;
hxpixel.images.png.FilterMethod.Peath.__enum__ = hxpixel.images.png.FilterMethod;
hxpixel.images.png.InterlaceMethod = $hxClasses["hxpixel.images.png.InterlaceMethod"] = { __ename__ : true, __constructs__ : ["None","Adam7"] }
hxpixel.images.png.InterlaceMethod.None = ["None",0];
hxpixel.images.png.InterlaceMethod.None.toString = $estr;
hxpixel.images.png.InterlaceMethod.None.__enum__ = hxpixel.images.png.InterlaceMethod;
hxpixel.images.png.InterlaceMethod.Adam7 = ["Adam7",1];
hxpixel.images.png.InterlaceMethod.Adam7.toString = $estr;
hxpixel.images.png.InterlaceMethod.Adam7.__enum__ = hxpixel.images.png.InterlaceMethod;
hxpixel.images.png.PngInfo = function() {
	this.palette = [];
	this.imageData = [];
	this.paletteTransparent = [];
};
$hxClasses["hxpixel.images.png.PngInfo"] = hxpixel.images.png.PngInfo;
hxpixel.images.png.PngInfo.__name__ = true;
hxpixel.images.png.PngInfo.prototype = {
	getPaletteLength: function() {
		if(this.palette == null) return 0;
		return this.palette.length;
	}
	,getRgbaImageData: function() {
		if(!Type.enumEq(this.colotType,hxpixel.images.png.ColorType.IndexedColor)) return this.imageData;
		var rgbaPalette = this.getRbgaPalette();
		var rgbaImageData = new Array();
		var _g1 = 0, _g = this.imageData.length;
		while(_g1 < _g) {
			var i = _g1++;
			rgbaImageData[i] = rgbaPalette[this.imageData[i]];
		}
		return rgbaImageData;
	}
	,getRbgaPalette: function() {
		var rgbaPalette = new Array();
		var transparentLength = this.paletteTransparent.length;
		var _g1 = 0, _g = this.palette.length;
		while(_g1 < _g) {
			var i = _g1++;
			rgbaPalette[i] = this.palette[i];
			if(i < transparentLength) rgbaPalette[i] += this.paletteTransparent[i] << 24; else rgbaPalette[i] += -16777216;
		}
		return rgbaPalette;
	}
	,__class__: hxpixel.images.png.PngInfo
}
var js = {}
js.Boot = function() { }
$hxClasses["js.Boot"] = js.Boot;
js.Boot.__name__ = true;
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) {
					if(cl == Array) return o.__enum__ == null;
					return true;
				}
				if(js.Boot.__interfLoop(o.__class__,cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
}
js.Browser = function() { }
$hxClasses["js.Browser"] = js.Browser;
js.Browser.__name__ = true;
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
$hxClasses.Math = Math;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = $hxClasses.String = String;
String.__name__ = true;
Array.prototype.__class__ = $hxClasses.Array = Array;
Array.__name__ = true;
Date.prototype.__class__ = $hxClasses.Date = Date;
Date.__name__ = ["Date"];
var Int = $hxClasses.Int = { __name__ : ["Int"]};
var Dynamic = $hxClasses.Dynamic = { __name__ : ["Dynamic"]};
var Float = $hxClasses.Float = Number;
Float.__name__ = ["Float"];
var Bool = $hxClasses.Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = $hxClasses.Class = { __name__ : ["Class"]};
var Enum = { };
haxe.Resource.content = [{ name : "16x16_16colors_001_gif", data : "s291:R0lGODlhEAAQALMAAP:::3tAVVM4RfSDZunx::Tk3ObGw:S%mdRNYJnhtu6uubNNgJ6T1LZwkORufrHD7CwAAAAAEAAQAAAEj5BJANC6iE7AiBDIIIrOQjwB9XxEeBwjEzBU8BAMEg57sFCAQCggUIQEgcFikAocEAFCoECNOpW%AcywoBYWBgRh4BBGBwpFQZ2e8QKp3AdOFFAWKWCwoV43mnoAfA8JCQ8oCgEleQGJXmtQS0o1DTc3DApKIXhASzo8CDAIDjxASTxaIQ4WeaYLDrCrnBQRADs"},{ name : "16x16_16colors_001_png", data : "s354:iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAMFBMVEX:::97QFVTOEX0g2bp8f:05NzmxsP0vpnUTWCZ4bburrmzTYCek9S2cJDkbn6xw%xJB9:eAAAAlElEQVR4nGM4c4Bj9w6GMwwMR5SajY1f%wsw8Ct5mBcbHzzAwPjlRLOFsTQDA2Oz0Aoj4c0CDOKNjqGBjsUbGTYXZ4dGZzg:ZGh0XhUVtfBwI4PACSVBIQVuAQYGBtmlURcZgTTv%pn:peQ2MjBIiYZGNW62Bsp8%XLKuhkowm3R3FHcZwE02ri5wq4bpEv63TsgDQBUvi23YQ0nRQAAAABJRU5ErkJggg"}];
haxe.Unserializer.DEFAULT_RESOLVER = Type;
haxe.Unserializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
haxe.ds.ObjectMap.count = 0;
haxe.zip.InflateImpl.LEN_EXTRA_BITS_TBL = [0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0,-1,-1];
haxe.zip.InflateImpl.LEN_BASE_VAL_TBL = [3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258];
haxe.zip.InflateImpl.DIST_EXTRA_BITS_TBL = [0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,-1,-1];
haxe.zip.InflateImpl.DIST_BASE_VAL_TBL = [1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577];
haxe.zip.InflateImpl.CODE_LENGTHS_POS = [16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15];
js.Browser.document = typeof window != "undefined" ? window.document : null;
Main.main();
})();
