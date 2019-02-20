var RCJSBridge = (function() {

	var rcCommandStatus = {
		CDVCommandStatus_NO_RESULT: 0,
		CDVCommandStatus_OK: 1,
		CDVCommandStatus_CLASS_NOT_FOUND_EXCEPTION: 2,
		CDVCommandStatus_INVALID_ACTION: 3,
		CDVCommandStatus_ERROR: 4
	};

	var utils = (function() {
		var typeName = function(val) {
			return Object.prototype.toString.call(val).slice(8, -1);
		}

		return {
			typeName: typeName
		}
	})();
	// -------------------------------------------------------------
	// copy from cordova.js
	var base64 = (function() {
		fromArrayBuffer = function(arrayBuffer) {
			var array = new Uint8Array(arrayBuffer);
			return uint8ToBase64(array);
		};

		toArrayBuffer = function(str) {
			var decodedStr = typeof atob !== 'undefined' ? atob(str) : Buffer.from(str, 'base64').toString('binary'); // eslint-disable-line no-undef
			var arrayBuffer = new ArrayBuffer(decodedStr.length);
			var array = new Uint8Array(arrayBuffer);
			for (var i = 0, len = decodedStr.length; i < len; i++) {
				array[i] = decodedStr.charCodeAt(i);
			}
			return arrayBuffer;
		};

		/* This code is based on the performance tests at http://jsperf.com/b64tests
		 * This 12-bit-at-a-time algorithm was the best performing version on all
		 * platforms tested.
		 */

		var b64_6bit = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
		var b64_12bit;

		var b64_12bitTable = function() {
			b64_12bit = [];
			for (var i = 0; i < 64; i++) {
				for (var j = 0; j < 64; j++) {
					b64_12bit[i * 64 + j] = b64_6bit[i] + b64_6bit[j];
				}
			}
			b64_12bitTable = function() {
				return b64_12bit;
			};
			return b64_12bit;
		};

		function uint8ToBase64(rawData) {
			var numBytes = rawData.byteLength;
			var output = '';
			var segment;
			var table = b64_12bitTable();
			for (var i = 0; i < numBytes - 2; i += 3) {
				segment = (rawData[i] << 16) + (rawData[i + 1] << 8) + rawData[i + 2];
				output += table[segment >> 12];
				output += table[segment & 0xfff];
			}
			if (numBytes - i === 2) {
				segment = (rawData[i] << 16) + (rawData[i + 1] << 8);
				output += table[segment >> 12];
				output += b64_6bit[(segment & 0xfff) >> 6];
				output += '=';
			} else if (numBytes - i === 1) {
				segment = (rawData[i] << 16);
				output += table[segment >> 12];
				output += '==';
			}
			return output;
		}
		// ----------------------------------------------------------------------

		return {
			fromArrayBuffer: fromArrayBuffer,
			toArrayBuffer: toArrayBuffer
		}
	})();

	var callbackMap = new Map();
	var callbackIndex = 0;

	var exec = function rcExec(callback, serviceName, action, arguments) {
		callbackIndex++;
		if (callbackIndex === Number.MAX_INTEGER) {
			callbackIndex = 0;
		}
		var callbackId = 'rc' + callbackIndex.toString() + Date.now();
		// 保证arguemnts是一个空数组
		arguments = arguments || [];
		arguments = massageArgsJsToNative(arguments);
		var command = [callbackId, serviceName, action, arguments];
		if (callback != null) {
			callbackMap.set(callbackId, callback);
		}
		console.log(`callbackId : ${callbackId}`);
		console.log(`serviceName: ${serviceName}`);
		console.log(`action : ${action}`);
		console.log(`arguments  : ${arguments}`);
		debugMap(callbackMap);
		window.webkit.messageHandlers.RCJSBridgeHandler.postMessage(command);
	}

	function massageArgsJsToNative(args) {
		if (!args || utils.typeName(args) != 'Array') {
			return args;
		}
		var ret = [];
		args.forEach(function(arg, i) {
			if (utils.typeName(arg) == 'ArrayBuffer') {
				ret.push({
					'CDVType': 'ArrayBuffer',
					'data': base64.fromArrayBuffer(arg)
				});
			} else {
				ret.push(arg);
			}
		});
		return ret;
	}

	function massageMessageNativeToJs(message) {
		if (message.CDVType == 'ArrayBuffer') {
			var stringToArrayBuffer = function(str) {
				var ret = new Uint8Array(str.length);
				for (var i = 0; i < str.length; i++) {
					ret[i] = str.charCodeAt(i);
				}
				return ret.buffer;
			};
			var base64ToArrayBuffer = function(b64) {
				return stringToArrayBuffer(atob(b64));
			};
			message = base64ToArrayBuffer(message.data);
		}
		return message;
	}

	var nativeCallback = function RCNativeCallback(callbackId, status, argumentsAsJson) {
		var callback = callbackMap.get(callbackId);
		if (callback == null || callback == 'undefined') {
			return;
		}
		callbackMap.delete(callbackId);
		var response = {}
		response.status = status;
		response.data = massageMessageNativeToJs(argumentsAsJson);
		callback(response);
	}

	function debugMap(myMap) {
		if (myMap.size === 0) {
			console.log("map size == 0!");
		}
		for (var [key, value] of myMap) {
			console.log(key + ' = ' + value);
		}
	}

	return {
		exec: exec,
		nativeCallback: nativeCallback,
		rcCommandStatus: rcCommandStatus
	}
})();
