/* Minification failed. Returning unminified contents.
(292,61-62): run-time error JS1195: Expected expression: >
(294,14-15): run-time error JS1195: Expected expression: )
(295,9-10): run-time error JS1002: Syntax error: }
(297,57-58): run-time error JS1004: Expected ';': {
(298,47-48): run-time error JS1195: Expected expression: >
(305,14-15): run-time error JS1195: Expected expression: )
(306,10-11): run-time error JS1195: Expected expression: ,
(308,66-67): run-time error JS1004: Expected ';': {
(330,2-3): run-time error JS1002: Syntax error: }
(333,42-43): run-time error JS1004: Expected ';': {
(348,1-2): run-time error JS1002: Syntax error: }
(995,3-4): run-time error JS1004: Expected ';': )
(2156,3-4): run-time error JS1004: Expected ';': )
(2421,3-4): run-time error JS1004: Expected ';': )
(2427,27-28): run-time error JS1004: Expected ';': {
(2657,3-4): run-time error JS1004: Expected ';': )
(2663,27-28): run-time error JS1004: Expected ';': {
(3418,76-77): run-time error JS1195: Expected expression: >
(3420,22-23): run-time error JS1195: Expected expression: )
(3421,78-79): run-time error JS1195: Expected expression: >
(3423,21-22): run-time error JS1002: Syntax error: }
(3430,13-14): run-time error JS1197: Too many errors. The file might not be a JavaScript file: .
(346,3-68): run-time error JS1018: 'return' statement outside of function: return new Function(code.replace(/[\r\t\n]/g, '')).apply(options)
(310,17-23): run-time error JS1018: 'return' statement outside of function: return
 */
/*Polyfill*/
// Production steps of ECMA-262, Edition 6, 22.1.2.1
if (!Array.from) {
    Array.from = (function () {
        var toStr = Object.prototype.toString;
        var isCallable = function (fn) {
            return typeof fn === 'function' || toStr.call(fn) === '[object Function]';
        };
        var toInteger = function (value) {
            var number = Number(value);
            if (isNaN(number)) { return 0; }
            if (number === 0 || !isFinite(number)) { return number; }
            return (number > 0 ? 1 : -1) * Math.floor(Math.abs(number));
        };
        var maxSafeInteger = Math.pow(2, 53) - 1;
        var toLength = function (value) {
            var len = toInteger(value);
            return Math.min(Math.max(len, 0), maxSafeInteger);
        };

        // The length property of the from method is 1.
        return function from(arrayLike/*, mapFn, thisArg */) {
            // 1. Let C be the this value.
            var C = this;

            // 2. Let items be ToObject(arrayLike).
            var items = Object(arrayLike);

            // 3. ReturnIfAbrupt(items).
            if (arrayLike == null) {
                throw new TypeError('Array.from requires an array-like object - not null or undefined');
            }

            // 4. If mapfn is undefined, then let mapping be false.
            var mapFn = arguments.length > 1 ? arguments[1] : void undefined;
            var T;
            if (typeof mapFn !== 'undefined') {
                // 5. else
                // 5. a If IsCallable(mapfn) is false, throw a TypeError exception.
                if (!isCallable(mapFn)) {
                    throw new TypeError('Array.from: when provided, the second argument must be a function');
                }

                // 5. b. If thisArg was supplied, let T be thisArg; else let T be undefined.
                if (arguments.length > 2) {
                    T = arguments[2];
                }
            }

            // 10. Let lenValue be Get(items, "length").
            // 11. Let len be ToLength(lenValue).
            var len = toLength(items.length);

            // 13. If IsConstructor(C) is true, then
            // 13. a. Let A be the result of calling the [[Construct]] internal method 
            // of C with an argument list containing the single item len.
            // 14. a. Else, Let A be ArrayCreate(len).
            var A = isCallable(C) ? Object(new C(len)) : new Array(len);

            // 16. Let k be 0.
            var k = 0;
            // 17. Repeat, while k < len… (also steps a - h)
            var kValue;
            while (k < len) {
                kValue = items[k];
                if (mapFn) {
                    A[k] = typeof T === 'undefined' ? mapFn(kValue, k) : mapFn.call(T, kValue, k);
                } else {
                    A[k] = kValue;
                }
                k += 1;
            }
            // 18. Let putStatus be Put(A, "length", len, true).
            A.length = len;
            // 20. Return A.
            return A;
        };
    }());
}
if (!Array.prototype.filter) {
    Array.prototype.filter = function (fun/*, thisArg*/) {
        'use strict';

        if (this === void 0 || this === null) {
            throw new TypeError();
        }

        var t = Object(this);
        var len = t.length >>> 0;
        if (typeof fun !== 'function') {
            throw new TypeError();
        }

        var res = [];
        var thisArg = arguments.length >= 2 ? arguments[1] : void 0;
        for (var i = 0; i < len; i++) {
            if (i in t) {
                var val = t[i];

                // NOTE: Technically this should Object.defineProperty at
                //       the next index, as push can be affected by
                //       properties on Object.prototype and Array.prototype.
                //       But that method's new, and collisions should be
                //       rare, so use the more-compatible alternative.
                if (fun.call(thisArg, val, i, t)) {
                    res.push(val);
                }
            }
        }

        return res;
    };
}
/*end polyfill*/

/*	base sb framework	*/
window.SBBase = {

	Utils: {
		
		hasEventListeners: !!window.addEventListener,

		document: window.document,

		addEvent: function(el, e, callback, capture)
		{
			if (!el) {
                return;
            }
			if (this.hasEventListeners) {
				el.addEventListener(e, callback, !!capture);
			} else {
				el.attachEvent('on' + e, callback);
			}
		},

		removeEvent: function(el, e, callback, capture)
		{
			if (this.hasEventListeners) {
				el.removeEventListener(e, callback, !!capture);
			} else {
				el.detachEvent('on' + e, callback);
			}
		},

		fireEvent: function(el, eventName, data)
		{
			var ev;

			if (document.createEvent) {
				ev = document.createEvent('HTMLEvents');
				ev.initEvent(eventName, true, false);
				ev = this.extend(ev, data, false, true);
				el.dispatchEvent(ev);
			} else if (document.createEventObject) {
				ev = document.createEventObject();
				ev = this.extend(ev, data, false, true);
				el.fireEvent('on' + eventName, ev);
			}
		},

		trim: function(str)
		{
			return str.trim ? str.trim() : str.replace(/^\s+|\s+$/g,'');
		},

		hasClass: function(el, cn)
		{
			return (' ' + el.className + ' ').indexOf(' ' + cn + ' ') !== -1;
		},

		hasParentClass: function(el, cn, depth)
		{
			depth = isNaN(depth) ? 5 : depth;
			return depth >= 0 && (this.hasClass(el, cn) || (el.parentNode && this.hasParentClass(el.parentNode, cn, --depth)));
		},
		
		addClass: function(el, cn)
		{
			if (!this.hasClass(el, cn)) {
				el.className = (el.className === '') ? cn : el.className + ' ' + cn;
			}
		},

		removeClass: function(el, cn)
		{
			el.className = this.trim((' ' + el.className + ' ').replace(' ' + cn + ' ', ' '));
		},

		isArray: function(obj)
		{
			return (/Array/).test(Object.prototype.toString.call(obj));
		},

		isDate: function(obj)
		{
			return (/Date/).test(Object.prototype.toString.call(obj)) && !isNaN(obj.getTime());
		},
	
		addDays: function(date, days) {
			var result = new Date(date);
			result.setDate(result.getDate() + days);
			return result;
		},

		extend: function(to, from, overwrite, forceReference)
		{
			var prop, hasProp;
			for (prop in from) {
				hasProp = to[prop] !== undefined;
				if (hasProp && typeof from[prop] === 'object' && from[prop] !== null && from[prop].nodeName === undefined) {
					if (this.isDate(from[prop])) {
						if (overwrite) {
							to[prop] = new Date(from[prop].getTime());
						}
					}
					else if (this.isArray(from[prop])) {
						if (overwrite) {
							to[prop] = from[prop].slice(0);
						}
					} else {
						to[prop] = this.extend(this.extend({}, to[prop], true), from[prop], overwrite);
					}
				} else if (overwrite || !hasProp) {
					if (forceReference) {
                        to[prop] = from[prop];
                    } else if (this.isDOM(from[prop])) {
                        to[prop] = from[prop];
                    } else if (typeof from[prop] === 'object' || this.isArray(from[prop])) {
						to[prop] = JSON.parse(JSON.stringify(from[prop]));
                    } else {
						to[prop] = from[prop];
					}
				}
			}
			return to;
		},

        //-----------------------------------
        // Determines if the @obj parameter is a DOM element
        isDOM: function(obj) {
            // DOM, Level2
            if ("HTMLElement" in window) {
                return (obj && obj instanceof HTMLElement);
            }
            // Older browsers
            return !!(obj && typeof obj === "object" && obj.nodeType === 1 && obj.nodeName);
        },

		adjustCalendar: function(calendar) {
			if (calendar.month < 0) {
				calendar.year -= Math.ceil(Math.abs(calendar.month)/12);
				calendar.month += 12;
			}
			if (calendar.month > 11) {
				calendar.year += Math.floor(Math.abs(calendar.month)/12);
				calendar.month -= 12;
			}
			return calendar;
		},
		
		getNodeOrCreate: function(id, tag) {
			var el = document.getElementById(id);
			if (!el){
				el = document.createElement(tag || 'div');
				el.id = id;
			}
			return el;
        },

        toMap: function(array, keyProperty) {
            var lookup = {};
            keyProperty = keyProperty || 'id';
            for (var i = 0, len = array.length; i < len; i++) {
                lookup[array[i][keyProperty]] = array[i];
            }
            return lookup;
        },

        flatten: function(array, property) {
            var result = [];
            for (var i = 0, len = array.length; i < len; i++) {
                result.push(array[i]);
                if (array[i][property])
                    result.push.apply(result, array[i][property]);
            }
            return result;
        },

        handleKeyDown: function (selector, callback) {
            var self = this;
            document.querySelectorAll(selector).forEach(el => {
                self.handleKeyDownOfElement(el, callback);
            });
        },

        handleKeyDownOfElement: function (el, callback) {
            el.addEventListener('keydown', e => {
                const keyDown = e.key !== undefined ? e.key : e.keyCode;
                if ((keyDown === 'Enter' || keyDown === 13) || (['Spacebar', ' '].indexOf(keyDown) >= 0 || keyDown === 32)) {
                    // (prevent default so the page doesn't scroll when pressing space)
                    e.preventDefault();
                    callback ? callback(el, e) : el.click();
                }
            });
        },

        setFocusNavigation: function (el, prev, next, checkFunc) {
            if (!el) {
                return;
            }
            this.addEvent(el, "keydown", function (e) {
                var keyCode = e.keyCode || e.which;
                if (keyCode == 9) {
                    var checkFuncPassed = !checkFunc || checkFunc();
                    if (e.shiftKey && checkFuncPassed) {
                        if (prev && checkFuncPassed) {
                            prev.focus();
                            e.preventDefault();
                        }
                    } else {
                        if (next && checkFuncPassed) {
                            next.focus();
                            e.preventDefault();
                        }
                    }
                }
            }, true);
        }
	},
	
	/* basic template engine*/
	TemplateEngine: function(html, options) {
		var re = /<%(.+?)?%>/g, reExp = /(^( )?(if|for|else|switch|case|break|{|}))(.*)?/g, code = 'var r=[];\n', cursor = 0, match;
		var add = function(line, js) {
			js? (code += line.match(reExp) ? line + '\n' : 'r.push(' + line + ');\n') :
				(code += line != '' ? 'r.push("' + line.replace(/"/g, '\\"') + '");\n' : '');
			return add;
		}
		while(match = re.exec(html)) {
			add(html.slice(cursor, match.index))(match[1], true);
			cursor = match.index + match[0].length;
		}
		add(html.substr(cursor, html.length - cursor));
		code += 'return r.join("");';
		return new Function(code.replace(/[\r\t\n]/g, '')).apply(options);
	}
};
/* end base framework*/;
/*!
 * SimpleBooking Guest Selector
 */

(function (root, factory)
{
    'use strict';

	root.GuestsSelector = factory(window.SBBase);
	
}(this, function (sbBase)
{
    'use strict';

	var sbUtils = sbBase.Utils;
	
    /**
     * defaults and localization
     */
    var defaults = {

        // bind the guests selector to a form field
        trigger: null,

        // automatically fit in the viewport even if it means repositioning from the position option
        reposition: true,
		
		// selected guests default
		selectedGuests: 'A',
		
		maxRooms: 4,
		minKidAge: 0,
		maxKidAge: 15,
		maxAdults: 6,
		maxKids: 4,
		
		// click on document is intended as cancel
		confirmOnBlur: false,

        // internationalization
        i18n: {
			room		: 'Room',
			adult		: 'Adult',
            adults		: 'Adults',
			kid			: 'Kid',
            kids      	: 'Kids',
            age			: 'Age',
			add		    : 'Add',
			addRoom     : 'Add another room',
            cancel		: 'Cancel',
			confirm		: 'Ok, done'
        },

        // callback function
        onSelect: null,
		onDraw: null,
		onOpen: null,
    },

	GuestRoom = function(roomAllocation, options) {
		this._init(roomAllocation, options);
	},
	
	GuestObject = function(guestAllocation, options) {
		this._init(guestAllocation, options);
	},
	
    /**
     * GuestsSelector constructor
     */
    GuestsSelector = function(options)
    {
        var self = this,
            opts = self.config(options);
			
		self._onMouseDown = function(e) {
			if (!self._v) {
                return;
            }
						
            e = e || window.event;
            var target = e.target || e.srcElement;
			
			if (target.correspondingUseElement)//ie fix
				target = target.correspondingUseElement.parentNode;
			if (target.tagName === 'use')
				target = target.parentNode;
			
            if (!target) {
                return;
            }
			
			var action = target.getAttribute('data-action');
			if (action){
				//e.preventDefault();
				switch (action) {
					case 'addGuest':
						var roomIndex = target.getAttribute('data-room-index');
						var guestType = target.getAttribute('data-target');
						var newRoomHtml = self._selectedGuestsObject.rooms[roomIndex].addGuest(guestType).draw(roomIndex, true);
						var oldRoom = document.querySelectorAll('#' + self.el.id + ' .sb__guests-room')[roomIndex];
						oldRoom.innerHTML = newRoomHtml;
						sbUtils.handleKeyDown(".sb__guests-counter svg[role='button']", function (el, e) {
							self._onMouseDown(e);
						});
						self._addKidAgeChangedEvent();
					break;
					case 'removeGuest':
						var roomIndex = target.getAttribute('data-room-index');
						var guestType = target.getAttribute('data-target');
						var newRoomHtml = self._selectedGuestsObject.rooms[roomIndex].removeGuest(guestType).draw(roomIndex, true);
						var oldRoom = document.querySelectorAll('#' + self.el.id + ' .sb__guests-room')[roomIndex];
						oldRoom.innerHTML = newRoomHtml;
						sbUtils.handleKeyDown(".sb__guests-counter svg[role='button']", function (el, e) {
							self._onMouseDown(e);
						});
						self._addKidAgeChangedEvent();
					break;
					case 'addRoom':
						var roomsCount = self._selectedGuestsObject.totalRooms();
						var newRoom = self._selectedGuestsObject.addRoom().buildNode(roomsCount);
						var oldRoom = document.querySelectorAll('#' + self.el.id + ' .sb__guests-room')[roomsCount-1];
						oldRoom.parentNode.insertBefore(newRoom, oldRoom.nextSibling);
						self.draw(true);
					break;
					case 'removeRoom':
						var roomIndex = target.getAttribute('data-room-index');
						if (self._selectedGuestsObject.removeRoom(roomIndex)){
							var oldRoom = document.querySelectorAll('#' + self.el.id + ' .sb__guests-room')[roomIndex];
							oldRoom.parentNode.removeChild(oldRoom);
							self.draw(true);
						}
					break;
					case 'cancelChanges':
						self._cancelChanges();
					case 'confirmChanges':
						self._confirmChanges();
					break;
				}
			}
		};
		
		self._confirmChanges = function () {

			if (!self._validate()) {
                return;
            }

			if (typeof self._o.onSelect === 'function') {
				self._o.onSelect.call(self, self._selectedGuestsObject);
			}

            self._toHide();
		};

		self._validate = function () {
            var valid = true;
            if (self._selectedGuestsObject) {
                document.querySelectorAll(".sb__guests-children-age-select").forEach(function (kidSelect) {
                    if (!kidSelect.value) {
                        sbUtils.addClass(kidSelect, "invalid");
                        valid = false;
                    } else {
                        sbUtils.removeClass(kidSelect, "invalid");
                    }
                });
			}
            return valid;
		};

		self._isValidAllocation = function () {
            const invalidKidAges = sbUtils.flatten(this._selectedGuestsObject.rooms, "kids")
				.filter(function (kidAge) { return (!kidAge && kidAge !== 0) || (kidAge > self._o.maxKidAge || kidAge < self._o.minKidAge); });
            return invalidKidAges.length === 0;
        },
		
		self._cancelChanges = function() {			
			self.setGuests(this.originalGuests, true);
			self._toHide();
		};
		
		self._toHide = function() {
			setTimeout(function() {
					self.hide();
					sbUtils.removeClass(opts.trigger.parentNode, 'focus');
			}, 100);
		}
			
		self._onKidAgeChanged = function(e) {
			
			if (!self._v) {
                return;
            }
						
            e = e || window.event;
            var target = e.target || e.srcElement;
			
			var roomIndex = target.getAttribute('data-room-index');
			var kidIndex = target.getAttribute('data-kid-index');
			self._selectedGuestsObject.rooms[roomIndex].changeKidAge(kidIndex, target.value);
            self._validate();
        },
		
		self._addKidAgeChangedEvent = function() {
			Array.from(document.querySelectorAll('.sb__guests .sb__guests-children-age-select')).forEach(function(elem) {
					sbUtils.addEvent(elem, 'change', self._onKidAgeChanged);
				});
		};
			
        self._onInputClick = function(e)
        {
			if (self._v) {
				if (self._o.confirmOnBlur){
					self._confirmChanges();
				} else {
					self._cancelChanges();
				}
            }
			else {
				sbUtils.addClass(self._o.trigger.parentNode, 'focus');	
				self.show();
            }
        };

        self._onClick = function(e)
        {
            e = e || window.event;
            var target = e.target || e.srcElement,
                pEl = target;
            if (!target) {
                return;
            }
            do {
                if (sbUtils.hasClass(pEl, 'sb__guests') || pEl === opts.trigger) {
                    return;
                }
            }
            while ((pEl = pEl.parentNode || target.correspondingUseElement));
			
			if (self._o.confirmOnBlur){
				self._confirmChanges();
			} else {
				self._cancelChanges();
			}
        };
		
        self.el = document.createElement('div');
		self.el.id = 'sb__guests_' + document.querySelectorAll('div.sb__guests').length;
        self.el.className = 'sb__guests sb-custom-widget-color sb-custom-widget-bg-color sb-custom-box-shadow-color';

        if (opts.trigger) {
			opts.trigger.parentNode.insertBefore(self.el, opts.trigger.nextSibling);
			//opts.trigger.appendChild(self.el);
        }
		this.hide();
		sbUtils.addEvent(opts.trigger, 'click', self._onInputClick);
		sbUtils.addEvent(self.el, 'mousedown', self._onMouseDown, true);
		
        /*Array.from(document.querySelectorAll('[data-action]')).forEach(function (el) {
			sbUtils.addEvent(self.el, 'mousedown', self._onMouseDown, true);
		});*/
		
    };


    /**
     * public GuestsSelector API
     */
    GuestsSelector.prototype = {


        /**
         * configure functionality
         */
        config: function(options)
        {
            if (!this._o) {
                this._o = sbUtils.extend({}, defaults, true);
            }

            var opts = sbUtils.extend(this._o, options, true);

			opts.trigger = (options.trigger && options.trigger.nodeName) ? options.trigger : null;
			
			this.setGuests(opts.selectedGuests);

            return opts;
        },

        /**
         * return a formatted string of the current guests selection
         */
        toString: function(format)
        {
			return this._selectedGuestsObject ? this._selectedGuestsObject.toString() : '';
        },

        /**
         * return the guests selection
         */
        getGuests: function()
        {
            return this._selectedGuestsObject;
        },

        /**
         * set the current guests selection
         */
        setGuests: function(guestAllocation, preventOnSelect)
        {
            if (typeof guestAllocation === 'string') {
                this._selectedGuestsObject = new GuestObject(guestAllocation, this._o);
            }
			else {
				this._selectedGuestsObject = guestAllocation;
			}
			
            if (!preventOnSelect && typeof this._o.onSelect === 'function') {
                this._o.onSelect.call(this, this._selectedGuestsObject);
			}
        },

        /**
         * refresh the HTML
         */
        draw: function(force)
        {
            if (!this._v && !force) {
                return;
            }
            var template = 
				'<%this._selectedGuestsObject.draw()%>' +
				'<div class="sb__panel-actions">' +
					'<button type="button" class="sb__btn sb__btn--secondary sb-custom-widget-element-hover-color sb-custom-widget-element-hover-bg-color" data-action="cancelChanges"><%this._o.i18n.cancel%></button>' + 
					'<button type="button" class="sb__btn sb__btn--primary sb-custom-button-bg-color sb-custom-button-color sb-custom-button-hover-bg-color" data-action="confirmChanges"><%this._o.i18n.confirm%></button>' +
				'</div>';

            this.el.innerHTML = SBBase.TemplateEngine(template, this);

			var self = this;
			setTimeout(function () {
				sbUtils.handleKeyDown(".sb__guests-room-header div[role='button']", function (el, e) {
					self._onMouseDown(e);
				});
				sbUtils.handleKeyDown(".sb__guests-room-header svg[role='button']", function (el, e) {
					self._onMouseDown(e);
				});
				sbUtils.handleKeyDown(".sb__guests-counter svg[role='button']", function (el, e) {
					self._onMouseDown(e);
				});
				sbUtils.handleKeyDown(".sb__panel-actions button", function (el, e) {
					self._onMouseDown(e);
				});

				var confirmChangesButton = document.querySelector("button[data-action='confirmChanges']");
				sbUtils.setFocusNavigation(confirmChangesButton, null, self._o.nextTab);

			}, 1);

            if (typeof this._o.onDraw === 'function') {
                this._o.onDraw(this);
			}
        },

        show: function()
        {
            if (!this._v) {
				var self = this;
                this._v = true;
                this.draw();
                if (typeof this._o.onOpen === 'function') {
                    this._o.onOpen.call(this);
                }
				sbUtils.addEvent(document, 'click', this._onClick);
				
				this._addKidAgeChangedEvent();
				this.el.style.display = 'block';
				this.originalGuests = this.toString();
            }
        },

        hide: function()
        {
            var v = this._v;
            if (v !== false) {
				sbUtils.removeEvent(document, 'click', this._onClick);
				this.el.style.display = 'none'
                this._v = false;
            }
        },
		
        destroy: function()
        {
            this.hide();
            if (this._o.trigger) {
				sbUtils.removeEvent(this._o.trigger, 'click', this._onInputClick);
            }
            if (this.el.parentNode) {
                this.el.parentNode.removeChild(this.el);
            }
		},

		validate: function () {
			if (!this._isValidAllocation()) {
				this.show();
                this._validate();
            }
		},

		isValidAllocation: function() {
            return this._isValidAllocation();
        }

    };
	
				
	GuestObject.prototype = {
		roomsSeparator: '|',
		rooms: [],
		options: {},
		template: 	'<div>' +
                        '<%for (var rIdx = 0; rIdx < this.rooms.length; rIdx++){%>' +
						  '<%this.rooms[rIdx].draw(rIdx)%>' +
					   '<%}%>' +
                    '</div>',
		
		_init: function(guestAllocation, options) {
			var self = this;
			self.options = options || self.options;
			self.rooms = [];
			guestAllocation.split(this.roomsSeparator).forEach(function (r) {
				self.addRoom(r);
			});
		},
		
		draw: function() {
			return SBBase.TemplateEngine(this.template, this);
		},
		
		addRoom: function(roomAllocation) {
			var newRoom = new GuestRoom(roomAllocation, this.options);
			this.rooms.push(newRoom);
			return newRoom;
		},
		
		removeRoom: function(roomIndex) {
			if (this.rooms.length > 1 && this.rooms.length > roomIndex){
				return this.rooms.splice(roomIndex, 1).length;	
			}
			return false;
		},
		
		totalAdults: function() {
			return this._totalInRooms('adults');
		},
		
		totalKids: function() {
			return this._totalInRooms('kids');
		},
		
		_totalInRooms: function(prop) {
			var count = 0;
			this.rooms.forEach(function(r){
				count += r[prop].length;
			});
			return count;
		},
		
		totalRooms: function() {
			return this.rooms.length;
		},
		
		toString: function() {
			var roomsString = [];
			this.rooms.forEach(function (r) {
				roomsString.push(r.toString());
			});
			return roomsString.join(this.roomsSeparator);
		}
	};
				
	GuestRoom.prototype = {
		guestsSeparator: ',',
		adults: [],
		kids: [],
		options: {
			minKidAge: 0,
			maxKidAge: 15
		},
		innerTemplate : '<div class="sb__guests-room-header">' +
                            '<span class="sb__guests-room-label"><%this.options.i18n.room%> <%this.index+1%></span>'+
						    '<%if(this.index > 0){%>'+
							    '<span class="sb__guests-room-remove"><svg tabindex="0" role="button" class="icon sb-custom-icon-color" data-action="removeRoom" data-room-index="<%this.index%>"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#remove-room"></use></svg></span>' +
						    '<%};%>' +
                            '<div class="sb__guests-room-header-divider"></div>' +
                            '<%if (this.index + 1  < this.options.maxRooms) {%>' +
                                '<div tabindex="0" role="button" class="sb__guests-add-room sb-custom-icon-color sb-custom-add-room-box-shadow-color" data-action="addRoom"><svg class="icon sb-custom-icon-color" data-action="addRoom"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#add-plus"></use></svg><%this.options.i18n.add%></div>' +
                            '<%}%>' +
                		'</div>' +
                            '<div class="sb__guests-adults sb-custom-label-hover">'+
							'<span class="sb__guests-adults-label sb-custom-label-hover-color"><%this.adults.length%> <%this.adults.length == 1 ? this.options.i18n.adult : this.options.i18n.adults%></span>'+
							'<div class="sb__guests-counter">'+
								'<svg tabindex="0" role="button" class="icon sb-custom-icon-color sb-custom-color-hover ' +
								'<%if (this.adults.length <= 1){%>' +
								'sb__guests-counter--disabled' +
								'<%}%>' +
								'" data-action="removeGuest" data-room-index="<%this.index%>" data-target="adults">'+
									'<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#remove"></use>'+
								'</svg>'+
								'<svg tabindex="0" role="button" class="icon sb-custom-icon-color sb-custom-color-hover ' +
								'<%if (this.adults.length >= this.options.maxAdults){%>' +
								'sb__guests-counter--disabled' +
								'<%}%>' + 
								'" data-action="addGuest" data-room-index="<%this.index%>" data-target="adults">'+
									'<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#add"></use>'+
								'</svg>'+
							'</div>'+
						'</div>' +
                        '<%if (this.options.maxKids > 0){%>' +
						    '<div class="sb__guests-children sb-custom-label-hover">'+
							    '<span class="sb__guests-children-label sb-custom-label-hover-color"><%this.kids.length%> <%this.kids.length == 1 ? this.options.i18n.kid : this.options.i18n.kids%></span>'+
							    '<div class="sb__guests-counter">'+
								    '<svg tabindex="0" role="button" class="icon sb-custom-icon-color sb-custom-color-hover ' +
								    '<%if (this.kids.length <= 0){%>' +
								    'sb__guests-counter--disabled' +
								    '<%}%>' + 
								    '" data-action="removeGuest" data-room-index="<%this.index%>" data-target="kids">'+
									    '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#remove"></use>'+
								    '</svg>'+
								    '<svg tabindex="0" role="button" class="icon sb-custom-icon-color sb-custom-color-hover ' +
								    '<%if (this.kids.length >= this.options.maxKids){%>' +
								    'sb__guests-counter--disabled' +
								    '<%}%>' + 
								    '" data-action="addGuest" data-room-index="<%this.index%>" data-target="kids">'+
									    '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#add"></use>'+
								    '</svg>'+
							    '</div>'+
						    '</div>' +
                        '<%}%>' +
						'<%if(this.kids.length){%><div class="sb__guests-children-age">'+
							'<span class="sb__guests-children-age-label sb-custom-label-color"><%this.options.i18n.age%></span>'+
							'<%for(var ageIdx = 0; ageIdx < this.kids.length; ageIdx++) {%>' +
								'<select class="sb__guests-children-age-select sb-custom-label-color sb-custom-bg-color sb-custom-box-shadow-color" data-kid-index="<%ageIdx%>" data-room-index="<%this.index%>">'+
			                        '<option value=""></option>' +
									'<%for (var i = this.options.minKidAge; i <= this.options.maxKidAge; i++) {%>' +							
										'<%if(this.kids[ageIdx]==i){%>' +
											'<option selected value="<%i%>"><%i%></option>'+
										'<%}else{%>' +
											'<option value="<%i%>"><%i%></option>'+
										'<%}%>' +
									'<%}%>' +
								'</select>' +
							'<%}%>' +
							'</select>'+
						'</div><%}%>',
						
		getFullTemplate: function() {
			return '<div class="sb__guests-room">'+ 
					this.innerTemplate + 
					'</div>';
		},
		
        i18n: {
			room		: 'Room',
			adult		: 'Adult',
            adults		: 'Adults',
			kid			: 'Kid',
            kids      	: 'Kids',
            age			: 'Age',
        }, 
		
		_init: function(roomAllocation, options) {
			this.options = options || this.options;
			roomAllocation = roomAllocation || 'A,A';
			var self = this;
			self.adults = [];
			self.kids = [];
			roomAllocation.split(this.guestsSeparator).forEach(function (g) {
				isNaN(g) ? self.addAdult() : self.addKid(parseInt(g));
			});
		},
		
		addGuest: function(guestType) {
			switch (guestType) {
				case 'adults':
					this.addAdult();
				break;
				case 'kids':
					this.addKid();
				break;
			}
			return this;
		},
		
		removeGuest: function(guestType) {
			switch (guestType) {
				case 'adults':
					if (this.adults.length > 1)//parameter?
						this.adults.pop();
				break;
				case 'kids':
					this.kids.pop(0);
				break;
			}
			return this;
		},
		
		addAdult: function() {
			if (this.adults.length < this.options.maxAdults)
				this.adults.push('A');
			return this;
		},
		
		addKid: function (age) {
			if (this.kids.length < this.options.maxKids){
				this.kids.push(0);
				this.changeKidAge(this.kids.length-1, age);	
			}
			return this;
		},
		
		changeKidAge: function(kidIndex, newAge) {
			this.kids[kidIndex] = isNaN(newAge) ? undefined : parseInt(newAge);
		},
		
		draw: function(index, innerHTML) {
			this.index = parseInt(index);
			return SBBase.TemplateEngine(innerHTML ? this.innerTemplate : this.getFullTemplate(), this);
		},
		
		buildNode: function(index) {
			var node = document.createElement('div');
			node.className = 'sb__guests-room';
			node.innerHTML = this.draw(index, true);
			return node;
		},
		
		toString: function() {
			return this.adults.concat(this.kids).join(this.guestsSeparator);
		}
	};


    return GuestsSelector;

}));
;
/*!
 * Pikaday
 * Copyright © 2014 David Bushell | BSD & MIT license | https://github.com/dbushell/Pikaday
 */

(function (root, factory)
{
    'use strict';
	root.Pikaday = factory(window.SBBase.Utils);
}(this, function (sbUtils)
{
    'use strict';

    /**
     * feature detection and helper functions
     */

    var isWeekend = function(date)
    {
        var day = date.getDay();
        return day === 0 || day === 6;
    },

    isLeapYear = function(year)
    {
        // solution by Matti Virkkunen: http://stackoverflow.com/a/4881951
        return year % 4 === 0 && year % 100 !== 0 || year % 400 === 0;
    },

    getDaysInMonth = function(year, month)
    {
        return [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
    },

    setToStartOfDay = function(date)
    {
        if (sbUtils.isDate(date)) date.setHours(0,0,0,0);
    },

    compareDates = function(a,b)
    {
        // weak date comparison (use setToStartOfDay(date) to ensure correct result)
        return a.getTime() === b.getTime();
    },

    isDateInRange = function(a,start,end)
    {
        // weak date comparison (use setToStartOfDay(date) to ensure correct result)
        return start.getTime() <= a.getTime() && a.getTime() <= end.getTime();
    },

    extend = function(to, from, overwrite)
    {
        var prop, hasProp;
        for (prop in from) {
            hasProp = to[prop] !== undefined;
            if (hasProp && typeof from[prop] === 'object' && from[prop] !== null && from[prop].nodeName === undefined) {
                if (sbUtils.isDate(from[prop])) {
                    if (overwrite) {
                        to[prop] = new Date(from[prop].getTime());
                    }
                }
                else if (sbUtils.isArray(from[prop])) {
                    if (overwrite) {
                        to[prop] = from[prop].slice(0);
                    }
                } else {
                    to[prop] = sbUtils.extend({}, from[prop], overwrite);
                }
            } else if (overwrite || !hasProp) {
                to[prop] = from[prop];
            }
        }
        return to;
    },

    adjustCalendar = function(calendar) {
        if (calendar.month < 0) {
            calendar.year -= Math.ceil(Math.abs(calendar.month)/12);
            calendar.month += 12;
        }
        if (calendar.month > 11) {
            calendar.year += Math.floor(Math.abs(calendar.month)/12);
            calendar.month -= 12;
        }
        return calendar;
    },

    /**
     * defaults and localization
     */
    defaults = {

        // bind the picker to a form field
        field: null,

        // automatically show/hide the picker on `field` focus (default `true` if `field` is set)
        bound: undefined,

        // position of the datepicker, relative to the field (default to bottom & left)
        // ('bottom' & 'left' keywords are not used, 'top' & 'right' are modifier on the bottom/left position)
        position: 'bottom left',

        // automatically fit in the viewport even if it means repositioning from the position option
        reposition: true,

        // the default output format for `.toString()` and `field` value
        format: 'YYYY-MM-DD',

        // the initial date to view when first opened
        defaultDate: null,

        // make the `defaultDate` the initial selected value
        setDefaultDate: false,

        // first day of week (0: Sunday, 1: Monday etc)
        firstDay: 0,

        // the default flag for moment's strict date parsing
        formatStrict: false,

        // the minimum/earliest date that can be selected
        minDate: null,
        // the maximum/latest date that can be selected
        maxDate: null,

        // number of years either side, or array of upper/lower range
        yearRange: 10,

        // used internally (don't config outside)
        minYear: 0,
        maxYear: 9999,
        minMonth: undefined,
        maxMonth: undefined,

        startRange: null,
        endRange: null,
		
		selectedRange: { start: setToStartOfDay(new Date())},
		
		//used for generic min range selectable
		minRangeLength: 1,
		
		checkInDays: [0, 1, 2, 3, 4, 5, 6],

        isRTL: false,

        // Render days of the calendar grid that fall in the next or previous month
        showDaysInNextAndPreviousMonths: false,

        // how many months are visible
        numberOfMonths: 2,
		
		// how many months to show when vertical displaying
		numberOfMonthsVertical: 1,

        // when numberOfMonths is used, this will help you to choose where the main calendar will be (default `left`, can be set to `right`)
        // only used for the first display or when a selected date is not visible
        mainCalendar: 'left',

        // Specify a DOM element to render the calendar in
        container: undefined,

        // Blur field when date is selected
        blurFieldOnSelect : true,

        // internationalization
        i18n: {
            //previousMonth : 'Previous Month',
            //nextMonth     : 'Next Month',
            months        : ['January','February','March','April','May','June','July','August','September','October','November','December'],
            //weekdays      : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
            weekdaysShort : ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
        },

        // Theme Classname
        theme: null,

        // events array
        events: [],

        // callback function
        onSelect: null,
        onOpen: null,
        onClose: null,
        onDraw: null
    },


    /**
     * templating functions to abstract HTML rendering
     */
    renderDayName = function(opts, day, abbr)
    {
        day += opts.firstDay;
        while (day >= 7) {
            day -= 7;
        }
        return abbr ? opts.i18n.weekdaysShort[day] : opts.i18n.weekdays[day];
    },

    renderDay = function(opts)
    {
        var arr = [];
        if (opts.isEmpty) {
            if (opts.showDaysInNextAndPreviousMonths) {
                arr.push('is-outside-current-month');
            } else {
                return '<li class="sb__calendar-day sb__calendar-day--past is-empty"></li>';
            }
        }
        var tabIndex = '';
        if (opts.isDisabled) {
            arr.push('sb__calendar-day--past');
        } else {
            arr.push('sb__calendar-day--valid');
            tabIndex = "tabindex=\"0\"";
		}
        if (opts.isToday) {
            arr.push('is-today');
        }
        if (opts.isSelected && !opts.isStart && !opts.isEnd) {
            arr.push('sb__calendar-day--range');
        }
        if (opts.hasEvent) {
            arr.push('has-event');
        }
        if (opts.isInRange) {
            arr.push('is-inrange');
        }
        if (opts.isStartRange) {
            arr.push('is-startrange');
        }
        if (opts.isEndRange) {
            arr.push('is-endrange');
        }
		if (!opts.isCheckinEnabled) {
            arr.push('sb__calendar-day--nocheckin');
        }
		
		opts.isStart && arr.push('sb__calendar-day--checkin');
		opts.isEnd && arr.push('sb__calendar-day--checkout');
		
        return '<li role="menuitem" ' + tabIndex + ' class="sb__calendar-day ' + arr.join(' ') +'" data-year="' + opts.year + '" data-month="' + opts.month + '" data-day="' + opts.day + '">' + opts.day +'</li>';
    },

    renderRow = function(days, isRTL)
    {
        return (isRTL ? days.reverse() : days).join('');
    },

    renderBody = function(rows)
    {
        return '<ul role="menu" aria-label="menu" class="sb__calendar-days">' + rows.join('') + '</ul>';
    },

    renderHead = function(opts)
    {
        var i, arr = [];
        for (i = 0; i < 7; i++) {
            arr.push('<li>' + renderDayName(opts, i, true) + '</li>');
        }
        return '<ul class="sb__calendar-weekdays">' + (opts.isRTL ? arr.reverse() : arr).join('') + '</ul>';
    },

    renderTitle = function(instance, c, year, month, refYear)
    {
        var i, j, arr,
            opts = instance._o,
            isMinYear = year === opts.minYear,
            isMaxYear = year === opts.maxYear,
            html = '<span class="sb__calendar-month-name">',
            monthHtml = opts.i18n.months[month],
            prev = true,
            next = true;

        html += monthHtml + " " + year;
		html += '</span>';

        return html;
    },
	
	renderMonthNavigationButtons = function(instance, c, year, month, refYear)
	{		
        var i, j, arr,
            opts = instance._o,
            isMinYear = year === opts.minYear,
            isMaxYear = year === opts.maxYear,
            html = '',
            prev = true,
            next = true;

        if (isMinYear && (month === 0 || opts.minMonth >= month)) {
            prev = false;
        }

        if (isMaxYear && (month === 11 || opts.maxMonth <= month)) {
            next = false;
        }

        if (c === 0 && prev) {
            html += '<div role="button" tabindex="0" class="sb__calendar-btn sb__calendar-btn--prev"><div class="sb__calendar-btn-icon"><svg class="icon"><use xlink:href="#arrow-left" /></svg></div></div>';
        }
        if (c === (instance._o.numberOfMonths - 1) && next) {
            html += '<div role="button" tabindex="0" class="sb__calendar-btn sb__calendar-btn--next"><div class="sb__calendar-btn-icon"><svg class="icon"><use xlink:href="#arrow-right" /></svg></div></div>';
        }
		return html;
	},

    renderTable = function(opts, data)
    {
        return renderHead(opts) + renderBody(data);
    },


    /**
     * Pikaday constructor
     */
    Pikaday = function(options)
    {
        var self = this,
            opts = self.config(options);
        self._onMouseDown = function(e)
        {
            if (!self._v) {
                return;
            }
            e = e || window.event;
            var target = e.target || e.srcElement;
            if (!target) {
                return;
            }

            self.onLiElementClick(target, e);
        };

        self.onLiElementClick = function (target, e) {
            if (!sbUtils.hasClass(target, 'sb__calendar-day--past')) {
                if (sbUtils.hasClass(target, 'sb__calendar-day') && !sbUtils.hasClass(target, 'is-empty') && !sbUtils.hasClass(target.parentNode, 'sb__calendar-day--past')) {
                    if (self._selectingStart) {
                        if (!sbUtils.hasClass(target, 'sb__calendar-day--nocheckin')) {
                            self._setSelectingEnd();
                            self._selectionIntent = 'end';
                            var date = new Date(target.getAttribute('data-year'), target.getAttribute('data-month'), target.getAttribute('data-day'));
                            var minEndDate = new Date(date);
                            minEndDate.setDate(date.getDate() + self._o.minRangeLength);//setting selectable range to start + nOfMinRangeDays
                            self._o.startRange = minEndDate;
                            var endRange = new Date(Math.max(self._range.end.getTime(), minEndDate.getTime()));
                            self.setRange(new Date(target.getAttribute('data-year'), target.getAttribute('data-month'), target.getAttribute('data-day')), endRange, false);
                        }
                    } else {
                        var endDate = new Date(target.getAttribute('data-year'), target.getAttribute('data-month'), target.getAttribute('data-day'));
                        var minEndDate = new Date(self._range.start);
                        minEndDate.setDate(self._range.start.getDate() + self._o.minRangeLength);//setting selectable range to start + nOfMinRangeDays
                        if (endDate.getTime() < minEndDate.getTime())
                            return;
                        self.setRange(self._range.start, endDate);
                        if (opts.bound) {
                            setTimeout(function () {
                                self.hide();
                                if (opts.blurFieldOnSelect && opts.field) {
                                    sbUtils.removeClass(opts.endField, 'focus');
                                    opts.endField.blur();
                                }
                            }, 100);
                        }
                    }
                }
                else if (sbUtils.hasParentClass(target, 'sb__calendar-btn--prev', 3)) {
                    self.prevMonth();
                }
                else if (sbUtils.hasParentClass(target, 'sb__calendar-btn--next', 3)) {
                    self.nextMonth();
                }
            }
            if (!sbUtils.hasClass(target, 'pika-select')) {
                // if this is touch event prevent mouse events emulation
                if (e.preventDefault) {
                    e.preventDefault();
                } else {
                    e.returnValue = false;
                    return false;
                }
            } else {
                self._c = true;
            }
        },
		
		self._setSelectingEnd = function() {			
			self._selectingStart = false;
            sbUtils.removeClass(opts.field, 'focus');
            opts.field.blur();
            sbUtils.addClass(opts.endField, 'focus');
		},
		
		self._setSelectingStart = function() {
			self._selectingStart = true;
            sbUtils.removeClass(opts.endField, 'focus');
            opts.endField.blur();
			sbUtils.addClass(opts.field, 'focus');	
		},
		
		self._onMouseOver = function(e) {
						
			if (!self._v) {
                return;
            }
            e = e || window.event;
            var target = e.target || e.srcElement;
            if (!target) {
                return;
            }					
					
            if (!sbUtils.hasClass(target, 'sb__calendar-day--past')) {
                if (sbUtils.hasClass(target, 'sb__calendar-day') && !sbUtils.hasClass(target, 'is-empty') && !sbUtils.hasClass(target.parentNode, 'sb__calendar-day--past')) {

                    var mouseOverDate = new Date(target.getAttribute('data-year'), target.getAttribute('data-month'), target.getAttribute('data-day'))
					if (!self._selectingStart && mouseOverDate.getTime() < self._range.start){
                        self._setSelectingStart();
                    }	
					if (self._selectionIntent == 'end' &&  self._selectingStart && mouseOverDate.getTime() > self._range.start){
						self._setSelectingEnd();
                    }

                    if (self._selectingStart) {
                        sbUtils.addClass(target, 'intent-selection-start');
                    }

					Array.from(document.getElementsByClassName('sb__calendar-day--valid')).forEach(function(el) {						
                        sbUtils.removeClass(el, 'intent-selection');
                        var date = new Date(el.getAttribute('data-year'), el.getAttribute('data-month'), el.getAttribute('data-day'));
						if (self._selectingStart && isDateInRange(date, mouseOverDate, self._range.end)){
							sbUtils.addClass(el, 'intent-selection');
                        }
						if (!self._selectingStart && isDateInRange(date, self._range.start, mouseOverDate)){
                            sbUtils.addClass(el, 'intent-selection');
						}
						
						
					});
                }
            }
        },

        self._onMouseLeave = function(e) {
						
			if (!self._v) {
                return;
            }
            e = e || window.event;
            var target = e.target || e.srcElement;
            if (!target) {
                return;
            }	
            sbUtils.removeClass(target, 'intent-selection-start');
        },

        self._onChange = function(e)
        {
            e = e || window.event;
            var target = e.target || e.srcElement;
            if (!target) {
                return;
            }
            if (sbUtils.hasClass(target, 'pika-select-month')) {
                self.gotoMonth(target.value);
            }
            else if (sbUtils.hasClass(target, 'pika-select-year')) {
                self.gotoYear(target.value);
            }
        };

        self._onInputChange = function(e)
        {
            var date;

            if (e.firedBy === self) {
                return;
            }
            else {
                date = new Date(Date.parse(opts.field.value));
            }
            if (sbUtils.isDate(date)) {
              self.setRange(date);
            }
            if (!self._v) {
                self.show();
            }
        };

        self._onInputClick = function(e)
        {
            if (self.isVisible() && self._selectionIntent == 'start') {
                self.hide();
                sbUtils.removeClass(self._o.field, 'focus');
                self._o.field.blur();
                return;
            }
            sbUtils.removeClass(self._o.endField, 'focus');
            self._o.endField.blur();
			sbUtils.addClass(self._o.field, 'focus');
			self._selectingStart = true;
			self._selectionIntent = 'start';
            self.show();
        };

        self._onEndInputClick = function(e)
        {
            if (self.isVisible() && self._selectionIntent == 'end') {
                self.hide();
                sbUtils.removeClass(self._o.endField, 'focus');
                return;
            }
            sbUtils.removeClass(self._o.field, 'focus');
            self._o.field.blur();
			sbUtils.addClass(self._o.endField, 'focus');
			self._selectingStart = false;
			self._selectionIntent = 'end';
			if (!self._v)
				self.show();
        };

        self._onClick = function(e)
        {
            e = e || window.event;
            var target = e.target || e.srcElement,
                pEl = target;
            if (!target) {
                return;
            }
            if (!sbUtils.hasEventListeners && sbUtils.hasClass(target, 'pika-select')) {
                if (!target.onchange) {
                    target.setAttribute('onchange', 'return;');
                    sbUtils.addEvent(target, 'change', self._onChange);
                }
            }
            do {
                if (sbUtils.hasClass(pEl, 'sb__calendar') || pEl === opts.trigger || pEl === opts.endTrigger) {
                    return;
                }
            }
            while ((pEl = pEl.parentNode));
            if (self._v && target !== opts.trigger && pEl !== opts.trigger && target !== opts.endTrigger & pEl !== opts.endTrigger) {
                self.hide();
				if (self._o.blurFieldOnSelect && self._o.field) {
                    sbUtils.removeClass(self._o.field, 'focus');
                    self._o.field.blur();
                    sbUtils.removeClass(self._o.endField, 'focus');
                    self._o.endField.blur();
				}
            }
        };

        self.el = document.createElement('div');
        self.el.className = 'sb__calendar' + (opts.isRTL ? ' is-rtl' : '') + (opts.theme ? ' ' + opts.theme : '');

        sbUtils.addEvent(self.el, 'mousedown', self._onMouseDown, true);
        sbUtils.addEvent(self.el, 'touchend', self._onMouseDown, true);
        sbUtils.addEvent(self.el, 'change', self._onChange);
        sbUtils.addEvent(document, 'keydown', self._onKeyChange);
        sbUtils.addEvent(self.el, 'mouseover', self._onMouseOver, true);
        sbUtils.addEvent(self.el, 'mouseleave', self._onMouseLeave, true);

        if (opts.field) {
            if (opts.container) {
                opts.container.appendChild(self.el);
            } else if (opts.bound) {
                document.body.appendChild(self.el);
            } else {
                opts.field.parentNode.insertBefore(self.el, opts.field.nextSibling);
            }
            sbUtils.addEvent(opts.field, 'change', self._onInputChange);

            if (!opts.defaultDate) {
				opts.defaultDate = new Date(Date.parse(opts.field.value));
                opts.setDefaultDate = true;
            }
        }

        var defDate = opts.defaultDate;

        if (sbUtils.isDate(defDate)) {
            if (opts.setDefaultDate) {
                self.setRange(defDate, true);
            } else {
                self.gotoDate(defDate);
            }
        } else {
            self.gotoDate(new Date());
        }

        if (opts.bound) {
            this.hide();
            self.el.className += ' is-bound';
            sbUtils.addEvent(opts.trigger, 'click', self._onInputClick);
            sbUtils.addEvent(opts.endTrigger, 'click', self._onEndInputClick);
        } else {
            this.show();
        }
    };


    /**
     * public Pikaday API
     */
    Pikaday.prototype = {


        /**
         * configure functionality
         */
        config: function(options)
        {
            if (!this._o) {
                this._o = sbUtils.extend({}, defaults, true);
            }

            var opts = sbUtils.extend(this._o, options, true);

            opts.isRTL = !!opts.isRTL;

            opts.field = (options.field && options.field.nodeName) ? options.field : null;

            opts.theme = (typeof opts.theme) === 'string' && opts.theme ? opts.theme : null;

            opts.bound = !!(opts.bound !== undefined ? opts.field && opts.bound : opts.field);

            opts.container = options.container;

            opts.trigger = (options.trigger && options.trigger.nodeName) ? options.trigger : opts.field;
			
            opts.endTrigger = (options.endTrigger && options.endTrigger.nodeName) ? options.endTrigger : options.endField;

            opts.disableWeekends = !!opts.disableWeekends;
			
			opts.disableDayFn = (typeof opts.disableDayFn) === 'function' ? opts.disableDayFn : null;

            var nom = parseInt(opts.numberOfMonths, 10) || 2;
            opts.numberOfMonths = nom > 4 ? 4 : nom;

            if (!sbUtils.isDate(opts.minDate)) {
                opts.minDate = false;
            }
            if (!sbUtils.isDate(opts.maxDate)) {
                opts.maxDate = false;
            }
            if ((opts.minDate && opts.maxDate) && opts.maxDate < opts.minDate) {
                opts.maxDate = opts.minDate = false;
            }
            if (opts.minDate) {
                this.setMinDate(opts.minDate);
            }
            if (opts.maxDate) {
                this.setMaxDate(opts.maxDate);
            }

            if (sbUtils.isArray(opts.yearRange)) {
                var fallback = new Date().getFullYear() - 10;
                opts.yearRange[0] = parseInt(opts.yearRange[0], 10) || fallback;
                opts.yearRange[1] = parseInt(opts.yearRange[1], 10) || fallback;
            } else {
                opts.yearRange = Math.abs(parseInt(opts.yearRange, 10)) || defaults.yearRange;
                if (opts.yearRange > 100) {
                    opts.yearRange = 100;
                }
            }
			
			this.setRange(opts.selectedRange.start, opts.selectedRange.end);

            return opts;
        },

        /**
         * return a formatted string of the current selection
         */
        toString: function(format)
        {
            return !sbUtils.isDate(this._d) ? '' : this._d.toDateString();
        },

        /**
         * return the date range object of the current selection
         */
        getRange: function()
        {
            return sbUtils.isDate(this._range.start) && sbUtils.isDate(this._range.start) ? { start: new Date(this._range.start.getTime()), end: new Date(this._range.end.getTime()) } : null;
        },

        /**
         * set the current selection
         */
        setRange: function(start, end, preventOnSelect)
        {
            if (!start) {
				this._range = null;

                if (this._o.field) {
                    this._o.field.value = '';
                    sbUtils.fireEvent(this._o.field, 'change', { firedBy: this });
                }

                return this.draw();
            }
            if (typeof start === 'string') {
                start = new Date(start);
            }
            if (typeof end === 'string') {
                end = new Date(end);
            }
            if (!sbUtils.isDate(start)) {
                return;
            }
			if (!end) {
				end = sbUtils.addDays(start, this._o.minRangeLength);
			}

            var min = this._o.minDate,
                max = this._o.maxDate;

            if (sbUtils.isDate(min) && start < min) {
                start = min;
				end = sbUtils.addDays(start, 1);
            } else if (sbUtils.isDate(max) && end > max) {
                end = max;
				start = sbUtils.addDays(start, -1);
            }

			this._range = this.range || {};
            this._range.start = new Date(start.getTime());
            this._range.end = new Date(end.getTime());
            setToStartOfDay(this._range.start);
            setToStartOfDay(this._range.end);
            this.gotoDate(this._range.start);

            if (this._o.field) {
                this._o.field.value = this.toString();
                sbUtils.fireEvent(this._o.field, 'change', { firedBy: this });
            }
            if (!preventOnSelect && typeof this._o.onSelect === 'function') {
                this._o.onSelect.call(this, this.getRange());
            }
        },

        /**
         * change view to a specific date
         */
        gotoDate: function(date)
        {
            var newCalendar = true;

            if (!sbUtils.isDate(date)) {
                return;
            }

            if (this.calendars) {
                var firstVisibleDate = new Date(this.calendars[0].year, this.calendars[0].month, 1),
                    lastVisibleDate = new Date(this.calendars[this.calendars.length-1].year, this.calendars[this.calendars.length-1].month, 1),
                    visibleDate = date.getTime();
                // get the end of the month
                lastVisibleDate.setMonth(lastVisibleDate.getMonth()+1);
                lastVisibleDate.setDate(lastVisibleDate.getDate()-1);
                newCalendar = (visibleDate < firstVisibleDate.getTime() || lastVisibleDate.getTime() < visibleDate);
            }

            if (newCalendar) {
                this.calendars = [{
                    month: date.getMonth(),
                    year: date.getFullYear()
                }];
                if (this._o.mainCalendar === 'right') {
                    this.calendars[0].month += 1 - this._o.numberOfMonths;
                }
            }

            this.adjustCalendars();
        },

        /*adjustDate: function(sign, days) {

            var day = this.getDate() || new Date();
            var difference = parseInt(days)*24*60*60*1000;

            var newDay;

            if (sign === 'add') {
                newDay = new Date(day.valueOf() + difference);
            } else if (sign === 'subtract') {
                newDay = new Date(day.valueOf() - difference);
            }

            this.setDate(newDay);
        },*/

        adjustCalendars: function() {
            this.calendars[0] = adjustCalendar(this.calendars[0]);
            for (var c = 1; c < this._o.numberOfMonths; c++) {
                this.calendars[c] = adjustCalendar({
                    month: this.calendars[0].month + c,
                    year: this.calendars[0].year
                });
            }
            this.draw();
        },

        gotoToday: function()
        {
            this.gotoDate(new Date());
        },

        /**
         * change view to a specific month (zero-index, e.g. 0: January)
         */
        gotoMonth: function(month)
        {
            if (!isNaN(month)) {
                this.calendars[0].month = parseInt(month, 10);
                this.adjustCalendars();
            }
        },

        nextMonth: function()
        {
            this.calendars[0].month++;
            this.adjustCalendars();
        },

        prevMonth: function()
        {
            this.calendars[0].month--;
            this.adjustCalendars();
        },

        /**
         * change view to a specific full year (e.g. "2012")
         */
        gotoYear: function(year)
        {
            if (!isNaN(year)) {
                this.calendars[0].year = parseInt(year, 10);
                this.adjustCalendars();
            }
        },

        /**
         * change the minDate
         */
        setMinDate: function(value)
        {
            if(value instanceof Date) {
                setToStartOfDay(value);
                this._o.minDate = value;
                this._o.minYear  = value.getFullYear();
                this._o.minMonth = value.getMonth();
            } else {
                this._o.minDate = defaults.minDate;
                this._o.minYear  = defaults.minYear;
                this._o.minMonth = defaults.minMonth;
                this._o.startRange = defaults.startRange;
            }

            this.draw();
        },

        /**
         * change the maxDate
         */
        setMaxDate: function(value)
        {
            if(value instanceof Date) {
                setToStartOfDay(value);
                this._o.maxDate = value;
                this._o.maxYear = value.getFullYear();
                this._o.maxMonth = value.getMonth();
            } else {
                this._o.maxDate = defaults.maxDate;
                this._o.maxYear = defaults.maxYear;
                this._o.maxMonth = defaults.maxMonth;
                this._o.endRange = defaults.endRange;
            }

            this.draw();
        },

        setStartRange: function(value)
        {
            this._o.startRange = value;
        },

        setEndRange: function(value)
        {
            this._o.endRange = value;
        },

        /**
         * refresh the HTML
         */
        draw: function(force)
        {
            if (!this._v && !force) {
                return;
            }
            var opts = this._o,
                minYear = opts.minYear,
                maxYear = opts.maxYear,
                minMonth = opts.minMonth,
                maxMonth = opts.maxMonth,
                html = '';

            if (this._y <= minYear) {
                this._y = minYear;
                if (!isNaN(minMonth) && this._m < minMonth) {
                    this._m = minMonth;
                }
            }
            if (this._y >= maxYear) {
                this._y = maxYear;
                if (!isNaN(maxMonth) && this._m > maxMonth) {
                    this._m = maxMonth;
                }
            }

            for (var c = 0; c < opts.numberOfMonths; c++) {
				html += renderMonthNavigationButtons(this, c, this.calendars[c].year, this.calendars[c].month, this.calendars[0].year);
                html += '<div class="sb__calendar-month">' + renderTitle(this, c, this.calendars[c].year, this.calendars[c].month, this.calendars[0].year) + this.render(this.calendars[c].year, this.calendars[c].month) + '</div>';
            }

            this.el.innerHTML = html;

            if (typeof this._o.onDraw === 'function') {
                this._o.onDraw(this);
            }

            if (opts.bound) {
                // let the screen reader user know to use arrow keys
                opts.field.setAttribute('aria-label', 'Use the arrow keys to pick a date');
            }

            var self = this;
            setTimeout(function () {
                sbUtils.handleKeyDown(".sb__calendar-month ul li", function (el, e) {
                    self.onLiElementClick(el, e);
                });
                sbUtils.handleKeyDown("div.sb__calendar-btn[role='button']", function (el, e) {
                    self.onLiElementClick(el, e);
                });
                document.querySelector("li[role='menuitem']").focus();
            }, 1);
        },
		
		setNumberOfMonths: function(numberOfMonths) {
			this._o.numberOfMonths = numberOfMonths;
			this.adjustCalendars();
			this.draw(true);
		},

        /*adjustPosition: function()
        {
            var field, pEl, width, height, viewportWidth, viewportHeight, scrollTop, left, top, clientRect;

            if (this._o.container) return;

            this.el.style.position = 'absolute';

            field = this._o.trigger;
            pEl = field;
            width = this.el.offsetWidth;
            height = this.el.offsetHeight;
            viewportWidth = window.innerWidth || document.documentElement.clientWidth;
            viewportHeight = window.innerHeight || document.documentElement.clientHeight;
            scrollTop = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;

            if (typeof field.getBoundingClientRect === 'function') {
                clientRect = field.getBoundingClientRect();
                left = clientRect.left + window.pageXOffset;
                top = clientRect.bottom + window.pageYOffset;
            } else {
                left = pEl.offsetLeft;
                top  = pEl.offsetTop + pEl.offsetHeight;
                while((pEl = pEl.offsetParent)) {
                    left += pEl.offsetLeft;
                    top  += pEl.offsetTop;
                }
            }

            // default position is bottom & left
            if ((this._o.reposition && left + width > viewportWidth) ||
                (
                    this._o.position.indexOf('right') > -1 &&
                    left - width + field.offsetWidth > 0
                )
            ) {
                left = left - width + field.offsetWidth;
            }
            if ((this._o.reposition && top + height > viewportHeight + scrollTop) ||
                (
                    this._o.position.indexOf('top') > -1 &&
                    top - height - field.offsetHeight > 0
                )
            ) {
                top = top - height - field.offsetHeight;
            }

            this.el.style.left = left + 'px';
            this.el.style.top = top + 'px';
        },*/

        /**
         * render HTML for a particular month
         */
        render: function(year, month)
        {
            var opts   = this._o,
                now    = new Date(),
                days   = getDaysInMonth(year, month),
                before = new Date(year, month, 1).getDay(),
                data   = [],
                row    = [];
            setToStartOfDay(now);
            if (opts.firstDay > 0) {
                before -= opts.firstDay;
                if (before < 0) {
                    before += 7;
                }
            }
            var previousMonth = month === 0 ? 11 : month - 1,
                nextMonth = month === 11 ? 0 : month + 1,
                yearOfPreviousMonth = month === 0 ? year - 1 : year,
                yearOfNextMonth = month === 11 ? year + 1 : year,
                daysInPreviousMonth = getDaysInMonth(yearOfPreviousMonth, previousMonth);
            var cells = days + before,
                after = cells;
            while(after > 7) {
                after -= 7;
            }
            cells += 7 - after;
            for (var i = 0, r = 0; i < cells; i++)
            {
                var day = new Date(year, month, 1 + (i - before)),
					isStart = compareDates(day, this._range.start),
					isEnd = compareDates(day, this._range.end),
                    isSelected = sbUtils.isDate(this._range.start) ? isDateInRange(day, this._range.start, this._range.end) : false,
                    isToday = compareDates(day, now),
                    hasEvent = opts.events.indexOf(day.toDateString()) !== -1 ? true : false,
                    isEmpty = i < before || i >= (days + before),
                    dayNumber = 1 + (i - before),
                    monthNumber = month,
                    yearNumber = year,
                    isStartRange = opts.startRange && compareDates(opts.startRange, day),
                    isEndRange = opts.endRange && compareDates(opts.endRange, day),
                    isInRange = opts.startRange && opts.endRange && opts.startRange < day && day < opts.endRange,
                    isDisabled = (opts.minDate && day < opts.minDate) ||
                                 (opts.maxDate && day > opts.maxDate) ||
                                 (opts.disableWeekends && isWeekend(day)) ||
                                 (opts.disableDayFn && opts.disableDayFn(day));

                if (isEmpty) {
                    if (i < before) {
                        dayNumber = daysInPreviousMonth + dayNumber;
                        monthNumber = previousMonth;
                        yearNumber = yearOfPreviousMonth;
                    } else {
                        dayNumber = dayNumber - days;
                        monthNumber = nextMonth;
                        yearNumber = yearOfNextMonth;
                    }
                }
                var dayConfig = {
                        day: dayNumber,
                        month: monthNumber,
                        year: yearNumber,
                        hasEvent: hasEvent,
						isStart: isStart,
						isEnd: isEnd,
                        isSelected: isSelected,
                        isToday: isToday,
                        isDisabled: isDisabled,
                        isEmpty: isEmpty,
                        isStartRange: isStartRange,
                        isEndRange: isEndRange,
                        isInRange: isInRange,
                        showDaysInNextAndPreviousMonths: opts.showDaysInNextAndPreviousMonths,
						isCheckinEnabled: this._o.checkInDays.indexOf(day.getDay()) >= 0
                    };

                row.push(renderDay(dayConfig));

                if (++r === 7) {
                    data.push(renderRow(row, opts.isRTL));
                    row = [];
                    r = 0;
                }
            }
            return renderTable(opts, data);
        },

        isVisible: function()
        {
            return this._v;
        },

        show: function()
        {
            if (!this.isVisible()) {
                this._v = true;
                this.draw();
                if (this._o.bound) {
                    sbUtils.addEvent(document, 'click', this._onClick);
                    //this.adjustPosition();
                }
                //sbUtils.removeClass(this.el, 'is-hidden');
                if (typeof this._o.onOpen === 'function') {
                    this._o.onOpen.call(this);
                }
				this.el.style.display = 'block';
            }
        },

        hide: function()
        {
            var v = this._v;
            if (v !== false) {
                if (this._o.bound) {
                    sbUtils.removeEvent(document, 'click', this._onClick);
                }
                //sbUtils.addClass(this.el, 'is-hidden');
				this.el.style.display = 'none'
                this._v = false;
                if (v !== undefined && typeof this._o.onClose === 'function') {
                    this._o.onClose.call(this);
                }
            }
        },

        /**
         * GAME OVER
         */
        destroy: function()
        {
            this.hide();
            sbUtils.removeEvent(this.el, 'mousedown', this._onMouseDown, true);
            sbUtils.removeEvent(this.el, 'touchend', this._onMouseDown, true);
            sbUtils.removeEvent(this.el, 'change', this._onChange);
            sbUtils.removeEvent(this.el, 'mouseover', this._onMouseOver, true);
            if (this._o.field) {
                sbUtils.removeEvent(this._o.field, 'change', this._onInputChange);
                if (this._o.bound) {
                    sbUtils.removeEvent(this._o.trigger, 'click', this._onInputClick);
                    sbUtils.removeEvent(this._o.endTrigger, 'click', this._onEndInputClick);
                }
            }
            if (this.el.parentNode) {
                this.el.parentNode.removeChild(this.el);
            }
        }

    };

    return Pikaday;

}));
;
/*!
 * SimpleBooking Promo Code Selector
 */

(function (root, factory)
{
    'use strict';

	root.PromoCodeSelector = factory(window.SBBase);
	
}(this, function (sbBase)
{
    'use strict';
	
	var sbUtils = sbBase.Utils;
	
    var defaults = {
	
		promoCode: '',
		
		trigger: null,
	
        // internationalization
        i18n: {
			inputLabel		: 'Insert code',
			inputPlaceholder: 'Promo',
            confirm			: 'Ok, done',
			cancel			: 'Cancel'
        },
		
		confirmOnBlur: true,

        // callback function
        onSelect: null,
		onClose: null,
		onOpen: null,
    },
	
    /**
     * PromoCodeSelector constructor
     */
    PromoCodeSelector = function(options)
    {
        var self = this,
            opts = self.config(options);
		
		self.template =
				'<span class="sb__footer-promo-label sb-custom-label-color"><%this._o.i18n.inputLabel%></span>' +
				'<input type="text" data-action="updatePromoCode" placeholder="<%this._o.i18n.inputPlaceholder%>" class="sb__footer-promo-input sb-custom-bg-color sb-custom-label-color sb-custom-box-shadow-color" value="<%this._promoCode%>">' +
				'<div class="sb__panel-actions">' +
					'<button type="button" class="sb__btn sb__btn--secondary sb-custom-color-hover sb-custom-widget-element-hover-bg-color" data-action="cancel"><%this._o.i18n.cancel%></button>' +
					'<button type="confirm" class="sb__btn sb__btn--primary sb-custom-button-bg-color sb-custom-button-hover-bg-color sb-custom-button-color" data-action="confirm"><%this._o.i18n.confirm%></button>' +
				'</div>';
		
		self._onMouseDown = function(e) {
			if (!self._v) {
                return;
            }
						
            e = e || window.event;
            var target = e.target || e.srcElement;
			
            if (!target) {
                return;
            }
			
			var action = target.getAttribute('data-action');
			if (action){
				//e.preventDefault();
				switch (action) {
					case 'confirm':		
						self._confirmChanges();
					break;
					case 'cancel':
						self._cancelChanges();
					break;
				}
			}
		};
		
		self._confirmChanges = function() {
			var self = this;
			var input = document.querySelector('.sb__footer-promo .sb__footer-promo-input');
			self.setPromoCode(input.value);
			if (typeof self._o.onSelect === 'function') {
				self._o.onSelect.call(self, self.getPromoCode());
			}
			setTimeout(function() {
					self.hide();
					sbUtils.removeClass(opts.trigger, 'focus');
				}, 100);
		};
		
		self._cancelChanges = function() {
			var self = this;
			self.setPromoCode(self.originalPromoCode, true);
			setTimeout(function() {
					self.hide();
					sbUtils.removeClass(opts.trigger, 'focus');
				}, 100);
		},
			
        self._onInputClick = function(e)
        {
			e.preventDefault();
			if (self._v) {
				if (self._o.confirmOnBlur){
					self._confirmChanges();
				} else {
					self._cancelChanges();
				}
			} else {
				sbUtils.addClass(self._o.trigger, 'focus');
				self.show();
			}
        };
		
		self._onSubmit = function(e) {
            e = e || window.event;
			e.preventDefault();
			self._confirmChanges();
		};

        self._onClick = function(e)
        {
            e = e || window.event;
            var target = e.target || e.srcElement,
                pEl = target;
            if (!target) {
                return;
            }
            do {
                if (sbUtils.hasClass(pEl, 'sb__footer-promo') || pEl === opts.trigger) {
                    return;
                }
            }
            while ((pEl = pEl.parentNode) || target.correspondingUseElement);
			
			if (self._o.confirmOnBlur){
				self._confirmChanges();
			} else {
				self._cancelChanges();
			}
        };
		
        self.el = document.createElement('form');
        self.el.className = 'sb__footer-promo sb-custom-widget-color sb-custom-widget-bg-color sb-custom-box-shadow-color';
		self.el.action = '/someaction';

		if (opts.trigger) {
			opts.trigger.parentNode.insertBefore(self.el, opts.trigger.nextSibling);
        }
		this.hide();
		sbUtils.addEvent(opts.trigger, 'click', self._onInputClick);
        sbUtils.addEvent(self.el, 'mousedown', self._onMouseDown, true);
        sbUtils.addEvent(self.el, 'submit', self._onSubmit, true);
		
    };


    /**
     * public PromoCodeSelector API
     */
    PromoCodeSelector.prototype = {

        /**
         * configure functionality
         */
        config: function(options)
        {
            if (!this._o) {
                this._o = sbUtils.extend({}, defaults, true);
            }

            var opts = sbUtils.extend(this._o, options, true);

            opts.trigger = (options.trigger && options.trigger.nodeName) ? options.trigger : null;
			
			this.setPromoCode(opts.promoCode, true);

            return opts;
        },
		
        /**
         * return the promo code selected
         */
        getPromoCode: function()
        {
            return this._promoCode;
        },

        /**
         * set the current promo code
         */
        setPromoCode: function(promoCode, preventOnSelect)
        {
			this._promoCode = promoCode;
			
            if (!preventOnSelect && typeof this._o.onSelect === 'function') {
                this._o.onSelect.call(this, this.getPromoCode());
            }
        },

        /**
         * refresh the HTML
         */
        draw: function(force)
        {
            if (!this._v && !force) {
                return;
            }

            this.el.innerHTML = sbBase.TemplateEngine(this.template, this);

            if (typeof this._o.onDraw === 'function') {
                this._o.onDraw(this);
            }
        },

        show: function()
        {
            if (!this._v) {
				var self = this;
                this._v = true;
                this.draw();
                if (typeof this._o.onOpen === 'function') {
                    this._o.onOpen.call(this);
                }
				sbUtils.addEvent(document, 'click', this._onClick);
				this.el.style.display = 'block';
				this.originalPromoCode = this.getPromoCode();
            }
        },

        hide: function()
        {
            var v = this._v;
            if (v !== false) {
                if (typeof this._o.onClose === 'function') {
                    this._o.onClose.call(this);
                }
				sbUtils.removeEvent(document, 'click', this._onClick);
				this.el.style.display = 'none'
                this._v = false;
            }
        },
		
        destroy: function()
        {
            this.hide();
            if (this._o.trigger) {
				sbUtils.removeEvent(this._o.trigger, 'click', this._onInputClick);
            }
            if (this.el.parentNode) {
                this.el.parentNode.removeChild(this.el);
            }
        }

    };


    return PromoCodeSelector;

}));
;
/*!
 * SimpleBooking Promo Code Selector
 */

(function (root, factory) {
    'use strict';

    root.PropertySelector = factory(window.SBBase);

}(this, function (sbBase) {
    'use strict';

    var sbUtils = sbBase.Utils;

    var defaults = {

        property: null,
        properties: [],

        trigger: null,

        // callback function
        onSelect: null,
        onClose: null,
        onOpen: null,
    },

    /**
     * PropertySelector constructor
     */
    PropertySelector = function (options) {
        var self = this,
            opts = self.config(options);
        //TODO supporto per un solo livello di gerarchia -> eventualmente implementare template ricorsivo per multi livello
        self.template =
				'<div class="sb__properties-options">' +
                    '<%for (var i = 0; i < this._o.properties.length; i++) {%>' +
					    '<div tabindex="0" role="button" class="sb__properties-option <%if (this._o.properties[i].children){%>sb__properties-option--parent<%}%> <%if (this.getProperty().id == this._o.properties[i].id){%>sb__properties-option--selected<%}%>" data-property-id="<%this._o.properties[i].id%>">' +
                            '<%this._o.properties[i].localizedNames ? (this._o.properties[i].localizedNames[this._o.lang] || this._o.properties[i].localizedNames[this._o.defaultLang] || this._o.properties[i].name) : this._o.properties[i].name %>' +
                        '</div>' +
                        '<%if (this._o.properties[i].children){%>' +
                            '<%for (var j = 0; j < this._o.properties[i].children.length; j++) {%>' +
                                '<div tabindex="0" role="button" class="sb__properties-option sb__properties-option--inner <%if (this.getProperty().id == this._o.properties[i].children[j].id){%>sb__properties-option--selected<%}%>" data-property-id="<%this._o.properties[i].children[j].id%>">' +
                                    '<%this._o.properties[i].children[j].localizedNames[this._o.lang] || this._o.properties[i].children[j].localizedNames[this._o.defaultLang] || this._o.properties[i].children[j].name %>' +
                                '</div>' +
                            '<%}%>' +
                        '<%}%>' +
                    '<%}%>' +
				'</div>';

        self._onMouseDown = function (e) {
            if (!self._v) {
                return;
            }

            e = e || window.event;
            var target = e.target || e.srcElement;

            if (!target) {
                return;
            }

            var propertyId = target.getAttribute('data-property-id');
            self._confirmProperty(propertyId);
        };

        self._confirmProperty = function (propertyId) {
            var self = this;
            if (!propertyId)
                return;

            var property = this._getPropertyById(propertyId);

            self.setProperty(property);
            if (typeof self._o.onSelect === 'function') {
                self._o.onSelect.call(self, self.getProperty());
            }
            setTimeout(function () {
                self.hide();
            }, 100);
        };

        self._getPropertyById = function (propertyId) {
            var flatProperties = sbUtils.flatten(self._o.properties, 'children');
            return sbUtils.toMap(flatProperties)[propertyId];
        };

        self._onInputClick = function (e) {
            e.preventDefault();
            if (self._v) {
                self.hide();
            } else {
                sbUtils.addClass(self._o.trigger.parentNode, 'focus');
                self.show();
            }
        };

        self._onClick = function (e) {
            e = e || window.event;
            var target = e.target || e.srcElement,
                pEl = target;
            if (!target) {
                return;
            }
            do {
                if (sbUtils.hasClass(pEl, 'sb__properties') || pEl === opts.trigger) {
                    return;
                }
            }
            while ((pEl = pEl.parentNode) || target.correspondingUseElement);

            self.hide();
        };

        self.el = document.createElement('div');
        self.el.className = 'sb__properties sb-custom-widget-color sb-custom-widget-bg-color sb-custom-box-shadow-color';;

        if (opts.trigger) {
            opts.trigger.parentNode.insertBefore(self.el, opts.trigger.nextSibling);
        }
        this.hide();
        sbUtils.addEvent(opts.trigger, 'click', self._onInputClick);
        sbUtils.addEvent(self.el, 'mousedown', self._onMouseDown, true);
        sbUtils.addEvent(self.el, 'submit', self._onSubmit, true);

    };

    /**
     * public PropertySelector API
     */
    PropertySelector.prototype = {

        /**
         * configure functionality
         */
        config: function (options) {
            if (!this._o) {
                this._o = sbUtils.extend({}, defaults, true);
            }

            var opts = sbUtils.extend(this._o, options, true);

            opts.trigger = (options.trigger && options.trigger.nodeName) ? options.trigger : null;

            this.setProperty(opts.property, true);

            return opts;
        },

        /**
         * return the property selected
         */
        getProperty: function () {
            return this._property;
        },

        /**
         * set the current property
         */
        setProperty: function (property, preventOnSelect) {
            this._property = property;

            if (!preventOnSelect && typeof this._o.onSelect === 'function') {
                this._o.onSelect.call(this, this.getProperty());
            }
        },

        /**
         * set the current property by id
         */
        setPropertyById: function (propertyId, preventOnSelect) {
            var property = this._getPropertyById(propertyId);
            property && this.setProperty(property, preventOnSelect);
        },

        /**
         * refresh the HTML
         */
        draw: function (force) {
            if (!this._v && !force) {
                return;
            }

            this.el.innerHTML = sbBase.TemplateEngine(this.template, this);
            var self = this;
            sbUtils.handleKeyDown(".sb__properties-options div[role='button']", function (el, e) {
                self._onMouseDown(e);
            });

            if (typeof this._o.onDraw === 'function') {
                this._o.onDraw(this);
            }
        },

        show: function () {
            if (!this._v) {
                var self = this;
                this._v = true;
                this.draw();
                if (typeof this._o.onOpen === 'function') {
                    this._o.onOpen.call(this);
                }
                sbUtils.addEvent(document, 'click', this._onClick);
                this.el.style.display = 'block';
            }
        },

        hide: function () {
            var v = this._v;
            if (v !== false) {
                if (typeof this._o.onClose === 'function') {
                    this._o.onClose.call(this);
                }
                sbUtils.removeEvent(document, 'click', this._onClick);
                this.el.style.display = 'none';
                sbUtils.removeClass(this._o.trigger.parentNode, 'focus');
                this._v = false;
            }
        },

        destroy: function () {
            this.hide();
            if (this._o.trigger) {
                sbUtils.removeEvent(this._o.trigger, 'click', this._onInputClick);
            }
            if (this.el.parentNode) {
                this.el.parentNode.removeChild(this.el);
            }
        }

    };

    return PropertySelector;

}));
;
/*!
 * SimpleBooking SearchBox
 */

(function (root, factory) {
    "use strict";

    root.SearchBox = factory(window.SBBase);

}(this, function (sbBase) {
    "use strict";

    var sbUtils = sbBase.Utils;

    var defaults = {
        Styles: {
            Footer: { ShowInline: false },
            Svg: '<svg class="sb__svg-sprite" xmlns="http://www.w3.org/2000/svg"><symbol id="add-plus" viewBox="0 0 24 24"><path class="st0" d="M13 7h-2v4H7v2h4v4h2v-4h4v-2h-4V7z"/></symbol><symbol id="add" viewBox="0 0 24 24"><path class="st0" d="M12 2c5.5 0 10 4.5 10 10s-4.5 10-10 10S2 17.5 2 12 6.5 2 12 2m0-2C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.6 0 12 0z"/><path class="st0" d="M13 7h-2v4H7v2h4v4h2v-4h4v-2h-4V7z"/></symbol><symbol id="arrow-left" viewBox="0 0 24 24"><path class="st0" d="M10 12c0-.1 0-.3.1-.4l3-3c.2-.2.5-.2.7 0s.2.5 0 .7L11.2 12l2.6 2.6c.2.2.2.5 0 .7s-.5.2-.7 0l-3-3c-.1 0-.1-.2-.1-.3z"/></symbol><symbol id="arrow-right" viewBox="0 0 24 24"><path class="st0" d="M14 12c0 .1 0 .3-.1.4l-3 3c-.2.2-.5.2-.7 0s-.2-.5 0-.7l2.6-2.6-2.6-2.6c-.2-.2-.2-.5 0-.7s.5-.2.7 0l3 3c.1-.1.1.1.1.2z"/></symbol><symbol id="calendar" viewBox="0 0 22 24"><path class="st0" d="M4 12h2v2H4zM7 12h2v2H7zM10 12h2v2h-2zM13 12h2v2h-2zM4 15h2v2H4zM7 15h2v2H7zM10 15h2v2h-2zM13 15h2v2h-2zM4 18h2v2H4zM7 18h2v2H7zM10 18h2v2h-2zM16 12h2v2h-2zM16 15h2v2h-2z"/><path class="st0" d="M19 2h-1V1c0-.6-.4-1-1-1s-1 .4-1 1v1H6V1c0-.6-.4-1-1-1S4 .4 4 1v1H3C1.3 2 0 3.3 0 5v16c0 1.7 1.3 3 3 3h16c1.7 0 3-1.3 3-3V5c0-1.7-1.3-3-3-3zm1 19c0 .6-.4 1-1 1H3c-.6 0-1-.4-1-1V10h18v11zm0-13H2V5c0-.6.4-1 1-1h1v1c0 .6.4 1 1 1s1-.4 1-1V4h10v1c0 .6.4 1 1 1s1-.4 1-1V4h1c.6 0 1 .4 1 1v3z"/></symbol><symbol id="chevron-down" viewBox="0 0 24 24"><path class="st0" d="M12 16c-.3 0-.5-.1-.7-.3l-6-6c-.4-.4-.4-1 0-1.4s1-.4 1.4 0l5.3 5.3 5.3-5.3c.4-.4 1-.4 1.4 0s.4 1 0 1.4l-6 6c-.2.2-.4.3-.7.3z"/></symbol><symbol id="edit" viewBox="0 0 13 11"><path class="st0" d="M10 9c0 .6-.4 1-1 1H2c-.6 0-1-.4-1-1V2c0-.6.4-1 1-1h7V0H2C.9 0 0 .9 0 2v7c0 1.1.9 2 2 2h7c1.1 0 2-.9 2-2V7h-1v2z"/><path class="st0" d="M4 7v2h2zM11 1.4l.6.6L7 6.6 6.4 6 11 1.4M11 0L5 6l2 2 6-6-2-2z"/></symbol><symbol id="promo" viewBox="0 0 18 11"><path class="st0" d="M5 3h1v1H5zM5 7h1v1H5zM5 5h1v1H5z"/><path transform="rotate(45.001 11.5 5.5)" class="st0" d="M11 1.3h1v8.5h-1z"/><path class="st0" d="M9.5 2C8.7 2 8 2.7 8 3.5S8.7 5 9.5 5 11 4.3 11 3.5 10.3 2 9.5 2zm0 2c-.3 0-.5-.2-.5-.5s.2-.5.5-.5.5.2.5.5-.2.5-.5.5zM13.5 6c-.8 0-1.5.7-1.5 1.5S12.7 9 13.5 9 15 8.3 15 7.5 14.3 6 13.5 6zm0 2c-.3 0-.5-.2-.5-.5s.2-.5.5-.5.5.2.5.5-.2.5-.5.5z"/><path class="st0" d="M17 0H1C.4 0 0 .4 0 1v9c0 .6.4 1 1 1h16c.6 0 1-.4 1-1V1c0-.6-.4-1-1-1zm0 10H6V9H5v1H1V1h4v1h1V1h11v9z"/></symbol><symbol id="remove-room" viewBox="0 0 24 24"><path class="st0" d="M9.2 7.8L7.8 9.2l2.8 2.8-2.8 2.8 1.4 1.4 2.8-2.8 2.8 2.8 1.4-1.4-2.8-2.8 2.8-2.8-1.4-1.4-2.8 2.8-2.8-2.8z"/></symbol><symbol id="remove" viewBox="0 0 24 24"><path class="st0" d="M12 2c5.5 0 10 4.5 10 10s-4.5 10-10 10S2 17.5 2 12 6.5 2 12 2m0-2C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.6 0 12 0z"/><path class="st0" d="M17 11H7v2h10v-2z"/></symbol></svg>',
            PseudoMediaQueries: {
                320: "sb-screen-xs",
                600: "sb-screen-s",
                720: "sb-screen-m",
                1024: "sb-screen-l",
                1200: "sb-screen-xl",
            },
            CustomStyleMappings: {
                FontFamily: [".sb { font-family: <%this.value%> !important}",
							".sb input { font-family: <%this.value%> !important}",
                            ".sb button { font-family: <%this.value%> !important}"],
                CustomColor: ".sb-custom-color { color: <%this.value%> !important }",
                CustomColorHover: [".sb-custom-color-hover:hover { color: <%this.value%> !important; fill: <%this.value%> !important }"],
                CustomBGColor: ".sb-custom-bg-color { background-color: <%this.value%> !important }",
                CustomFieldBackgroundColor: ".sb-custom-field-bg-color { background-color: <%this.value%> !important }",
                CustomLabelColor: ".sb-custom-label-color { color: <%this.value%> !important }",
                CustomLabelHoverColor: ".sb-custom-label-hover:hover .sb-custom-label-hover-color {color: <%this.value%> !important;}",
                CustomButtonColor: ".sb-custom-button-color { color: <%this.value%> !important}",
                CustomButtonBGColor: ".sb-custom-button-bg-color { background-color: <%this.value%> !important }",
                CustomButtonHoverBGColor: ".sb-custom-button-hover-bg-color:hover { background-color: <%this.value%> !important }",
                CustomIconColor: ".sb-custom-icon-color {fill: <%this.value%> !important; color: <%this.value%> !important }",
                CustomLinkColor: ".sb-custom-link-color {color: <%this.value%> !important;}",
                CustomWidgetColor: ".sb-custom-widget-color { color: <%this.value%> !important }",
                CustomWidgetBGColor: [".sb-custom-widget-bg-color { background-color: <%this.value%> !important }",
										".sb-custom-widget-border-color { border-color: <%this.value%> !important }"],
                //CustomWidgetElementColor: '.sb-custom-widget-element-color { color: <%this.value%> !important }',
                //CustomWidgetElementBGColor: ['.sb-custom-widget-element-bg-color { background-color: <%this.value%> !important }'],
                CustomWidgetElementHoverColor: ".sb-custom-widget-element-hover-color:hover { color: <%this._colorToRgba(this.value, 0.85)%> !important }",
                CustomWidgetElementHoverBGColor: ".sb-custom-widget-element-hover-bg-color:hover { background-color: <%this._colorToRgba(this.value, 0.1)%> !important }",
                //CustomWidgetElementHoverBoxColor: '.sb-custom-widget-element-hover-box-color:hover { box-shadow: inset 0 0 0 1px <%this.value%> !important }',
                CustomBoxShadowColor: ".sb-custom-box-shadow-color {box-shadow: inset 0 0 0 1px <%this._colorToRgba(this.value, 0.15)%> !important }",
                CustomBoxShadowColorFocus: [".focus .sb-custom-box-shadow-color-focus {box-shadow: inset 0 0 0 2px <%this.value%> !important }",
											".sb-custom-box-shadow-color:focus {box-shadow: inset 0 0 0 2px <%this.value%> !important }",
											".sb-custom-box-shadow-color { border-color: <%this.value%> !important }",
											".sb-custom-box-shadow-color-focus:before { border-color: transparent transparent <%this.value%> transparent !important }",
											".sb-custom-box-shadow-color:before { border-color: transparent transparent <%this.value%> transparent !important }",
											".sb-open-top .sb-custom-box-shadow-color:before { border-color: <%this.value%> transparent transparent transparent !important }",
                                            ".sb__guests-room-header-divider:before { background: <%this._colorToRgba(this.value, 0.2)%> !important }"],
                CustomBoxShadowColorHover: ".sb-custom-box-shadow-color-hover:hover {box-shadow: inset 0 0 0 1px <%this._colorToRgba(this.value, 0.3)%> !important }",
                /*calendar ccs override*/
                CustomIntentSelectionColor: [
				".sb__calendar-day--valid:hover {color:<%this._colorToRgba(this.value, .85)%>}",
				".intent-selection {color:<%this._colorToRgba(this.value, .85)%>}"],
                CustomIntentSelectionDaysBGColor: [
				".sb__calendar-day--valid:hover {background: <%this._colorToRgba(this.value, .1)%>}",
				".intent-selection {background:<%this._colorToRgba(this.value, .1)%>}",
                ".sb__properties-option:hover {background:<%this._colorToRgba(this.value, .3)%>}"],
                CustomSelectedDaysColor: [
				".sb__calendar-day--valid.sb__calendar-day--checkin {color: <%this.value%> }",
				".sb__calendar-day--valid.sb__calendar-day--checkout {color: <%this.value%> }",
				".sb__calendar-day--valid.sb__calendar-day--checkin.intent-selection {color: <%this.value%> }",
				".sb__calendar-day--valid.sb__calendar-day--checkout.intent-selection {color: <%this.value%> }",
				".sb__calendar-day--valid.sb__calendar-day--checkin:hover {color: <%this.value%> ; box-shadow: 0 0 0 0 ;}",
				".sb__calendar-day--valid.sb__calendar-day--checkout:hover {color: <%this.value%> ; box-shadow: 0 0 0 0 ;}",
				".sb__calendar-day--valid.sb__calendar-day--range {color: <%this.value%> !important}"],
                CustomAccentColor: [
				".sb__calendar-btn {box-shadow: inset 0 0 0 1px <%this.value%> }",
				".sb__calendar-btn:hover {color: <%this.value%> ; box-shadow: inset 0 0 0 2px <%this.value%> }",
				".sb__calendar-btn-icon .icon {fill: <%this.value%> }",
				".sb__calendar-day--valid:hover {box-shadow: inset 0 0 0 2px <%this.value%> }",
				".sb__calendar-day--checkin:before {border-color: transparent transparent <%this.value%> transparent }",
				".sb__calendar-day--checkout:before {border-color: <%this.value%> transparent transparent transparent }",
				".sb__calendar-day--valid.sb__calendar-day--checkin {background: <%this._colorToRgba(this.value, 0.7)%> }",
				".sb__calendar-day--valid.sb__calendar-day--checkout {background: <%this._colorToRgba(this.value, 0.7)%> }",
				".sb__calendar-day--valid.sb__calendar-day--checkin.intent-selection {background: <%this._colorToRgba(this.value, 0.7)%> }",
				".sb__calendar-day--valid.sb__calendar-day--checkout.intent-selection {background: <%this._colorToRgba(this.value, 0.7)%> }",
				".sb__calendar-day--checkin:focus {background: <%this.value%> }",
				".sb__calendar-day--checkout:focus {background: <%this.value%> }",
				".sb__calendar-day--valid.sb__calendar-day--range {background: <%this.value%> }",
				".sb__calendar-day--valid.sb__calendar-day--range.intent-selection {background: <%this.value%> }",
				".sb__calendar-day--valid.sb__calendar-day--range:hover {box-shadow: inset 0 0 0 2px <%this.value%> }",
				".intent-selection:hover {box-shadow: inset 0 0 0 2px <%this.value%> }"],
                CustomAccentColorHover: [
				".sb__calendar-day--valid.sb__calendar-day--range.sb__calendar-day--valid:hover {background: <%this.value%> }",
				".sb__calendar-day--checkin:hover:before {border-color: transparent transparent <%this.value%> transparent }",
				".sb__calendar-day--checkout:hover:before {border-color: <%this.value%> transparent transparent transparent }"],
                CustomCalendarBackgroundColor: [".sb__calendar {background: <%this.value%> }",
                    ".sb__calendar-day {border: 1px solid <%this.value%> }"],
                CustomKidAgeInvalidColor: [".sb__guests-room .sb__guests-children-age .sb__guests-children-age-select.invalid { box-shadow: inset 0 0 0 3px <%this.value%> !important}"]
                /*end calendar css override*/
            },
            Theme: "dark",//light-pink, dark
            Themes: {
                'light-pink': {
                    CustomColor: "#5D576B",
                    CustomColorHover: "#de4d70",
                    CustomBGColor: "#f1f1f1",
                    CustomFieldBackgroundColor: "#fff",
                    CustomLabelColor: "#5D576B",
                    CustomLabelHoverColor: "#de4d70",
                    CustomButtonColor: "#fff",
                    CustomButtonBGColor: "#79C99E",
                    CustomButtonHoverBGColor: "#86cea8",
                    CustomIconColor: "#F7567C",
                    CustomLinkColor: "#F7567C",
                    CustomWidgetColor: "#5D576B",
                    CustomWidgetBGColor: "#fff",
                    //CustomWidgetElementColor: '#fff',
                    //CustomWidgetElementBGColor: '#F7567C',
                    CustomWidgetElementHoverColor: "#5D576B",
                    CustomWidgetElementHoverBGColor: "#de4d70",
                    //CustomWidgetElementHoverBoxColor: '#F7567C',
                    CustomBoxShadowColor: "#5D576B",
                    CustomBoxShadowColorFocus: "#F7567C",
                    CustomBoxShadowColorHover: "#5D576B",
                    /*calendar css override*/
                    CustomIntentSelectionColor: "#5D576B",
                    CustomIntentSelectionDaysBGColor: "#5D576B",
                    CustomSelectedDaysColor: "#fff",
                    CustomAccentColor: "#F7567C",
                    CustomAccentColorHover: "#de4d70",
                    CustomCalendarBackgroundColor: "#fff"
                },
                'dark': {
                    CustomColor: "#f1f1f1",
                    CustomColorHover: "#9bc3bd",
                    CustomBGColor: "#0B2027",
                    CustomFieldBackgroundColor: "#0B2027",
                    CustomLabelColor: "#f1f1f1",
                    CustomLabelHoverColor: "#70A9A1",
                    CustomButtonColor: "#fff",
                    CustomButtonBGColor: "#70A9A1",
                    CustomButtonHoverBGColor: "#7eb2aa",
                    CustomIconColor: "#70A9A1",
                    CustomLinkColor: "#70A9A1",
                    CustomWidgetColor: "#f1f1f1",
                    CustomWidgetBGColor: "#0B2027",
                    //CustomWidgetElementColor: '#fff',
                    //CustomWidgetElementBGColor: '#70A9A1',
                    CustomWidgetElementHoverColor: "#f1f1f1",
                    CustomWidgetElementHoverBGColor: "#f1f1f1",
                    //CustomWidgetElementHoverBoxColor: '#70A9A1',
                    CustomBoxShadowColor: "#f1f1f1",
                    CustomBoxShadowColorFocus: "#70A9A1",
                    CustomBoxShadowColorHover: "#f1f1f1",
                    /*calendar css override*/
                    CustomIntentSelectionColor: "#f1f1f1",
                    CustomIntentSelectionDaysBGColor: "#f1f1f1",
                    CustomSelectedDaysColor: "#0B2027",
                    CustomAccentColor: "#70A9A1",
                    CustomAccentColorHover: "#9bc3bd",
                    CustomCalendarBackgroundColor: "#0B2027"
                },
                'portal': {
                    CustomColor: "#5a5b5c",
                    CustomColorHover: "#4d7b9e",
                    CustomBGColor: "#fff",
                    CustomFieldBackgroundColor: "#fff",
                    CustomLabelColor: "#5a5b5c",
                    CustomLabelHoverColor: "#777",
                    CustomButtonColor: "#fff",
                    CustomButtonBGColor: "#77c720",
                    CustomButtonHoverBGColor: "#85cd36",
                    CustomIconColor: "#004274",
                    CustomLinkColor: "#004274",
                    CustomWidgetColor: "#5a5b5c",
                    CustomWidgetBGColor: "#fff",
                    //CustomWidgetElementColor: '#fff',
                    //CustomWidgetElementBGColor: '#F7567C',
                    CustomWidgetElementHoverColor: "#5a5b5c",
                    CustomWidgetElementHoverBGColor: "#777",
                    //CustomWidgetElementHoverBoxColor: '#F7567C',
                    CustomBoxShadowColor: "#5a5b5c",
                    CustomBoxShadowColorFocus: "#004274",
                    CustomBoxShadowColorHover: "#5a5b5c",
                    /*calendar css override*/
                    CustomIntentSelectionColor: "#5a5b5c",
                    CustomIntentSelectionDaysBGColor: "#5a5b5c",
                    CustomSelectedDaysColor: "#fff",
                    CustomAccentColor: "#004274",
                    CustomAccentColorHover: "#004274b3",
                    CustomCalendarBackgroundColor: "#fff",
                    FontFamily: "Roboto, Arial, sans-serif"
                }
            },
            CustomKidAgeInvalidColor: "red"
        },

        MainContainerId: "sb-container",

        onNoPropertySelected: function() {
            alert(this.Localizations.Labels.PropertyNotSelected[this.CodLang]);
        },

        customParamsDecorator: function() {
            return "";
        },

        FieldIds: {
            Container: "sb-form-container",
            Form: "sb__form",
            Property: "sb__form-field--property",
            AvailabilityButton: "sb__form-field--checkavailability",
            ReservationEditLink: "sb__form-field--reservationedit",
            Checkin: "sb__form-field--checkin",
            Checkout: "sb__form-field--checkout",
            Guests: "sb__form-field--guests",
            Promo: "sb__footer-promo-wrapper",
            AvailabilityFormContent: "sb__availability-form-content",
            HiddenSearchForm: "sb__hidden_search_form"
        },

        Templates: {
            Property: '<span class="sb__form-field-property sb_custom-label-color" data-property-id="<%this.id%>"><%this.name%></span>' +
					'<div class="sb__form-field-icon">' +
						'<svg class="icon sb-custom-icon-color">' +
							'<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#chevron-down"></use>' +
						"</svg>" +
					"</div>",
            Date:   '<span class="sb__form-field-date-number"><%this.date%></span>' +
					'<div class="sb__form-field-date-wrapper">' +
						'<span class="sb__form-field-month-year"><%this.month%> <%this.year%></span>' +
						'<span class="sb__form-field-weekday"><%this.weekDay%></span>' +
					"</div>" +
					'<div class="sb__form-field-icon">' +
						'<svg class="icon sb-custom-icon-color">' +
							'<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#calendar"></use>' +
						"</svg>" +
					"</div>",
            Guests: '<span class="sb__form-field-date-number"><%this.adults%></span>' +
					'<div class="sb__form-field-date-wrapper">' +
						'<span class="sb__form-field-guests"><%this.adultsLabel%><%this.children > 0 ? " + " + this.children + " " + this.childrenLabel : "" %></span>' +
						'<span class="sb__form-field-rooms"><%this.roomsLabel%> <%this.rooms%></span>' +
					"</div>" +
					'<div class="sb__form-field-icon">' +
						'<svg class="icon sb-custom-icon-color">' +
							'<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#chevron-down"></use>' +
						"</svg>" +
					"</div>",
            Promo: '<svg class="icon sb-custom-icon-color">' +
						'<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#promo"></use>' +
					"</svg>" +
                '<%this._o.Localizations.Labels.PromoCode[this._o.CodLang]%><span class="sb__footer-link--promo-value"><%this._currentValue.promoCode%></span>',
            AvailabilityPopoverContent:
                "<div id='<%this.containerId%>'>" +
                    "<div class='loading'></div>" +
                    "<%this.iframeContent%>" +
                "</div>",
            IFrameContent: "<iframe style='display: block' width='100%' height='0' scrolling='no' src='<%this.iframeSrc%>' sandbox='allow-scripts allow-forms allow-same-origin allow-modals allow-popups' frameBorder='0'></iframe>"
        }
    },

    /**
     * SearchBox constructor
     */
    SearchBox = function (options) {
        var self = this,
            opts = self.config(options);
        self.template =
			'<div id="<%this._o.FieldIds.Form%>" class="sb__form">' +
                '<div class="sb__property">' +
					'<div class="sb__form-field">' +
						'<%if (!this._o.HideFieldLabels){%><span class="sb__form-field-label sb-custom-label-color"><%this._o.Localizations.Labels.SelectProperty[this._o.CodLang]%></span><%}%>' +
						'<div id="<%this._o.FieldIds.Property%>" tabindex="0" role="button" class="sb__form-field-input sb-custom-box-shadow-color sb-custom-box-shadow-color-hover sb-custom-box-shadow-color-focus sb-custom-field-bg-color">' +
							"<%this._renderPropertyField()%>" +
						"</div>" +
					"</div>" +
                "</div>" +
				'<div class="sb__dates">' +
					'<div id="<%this._o.FieldIds.Checkin%>" class="sb__form-field sb__form-field--checkin">' +
                        '<%if (!this._o.HideFieldLabels){%><span class="sb__form-field-label sb-custom-label-color"><%this._o.Localizations.Labels["CheckinDate"][this._o.CodLang]%></span><%}%>' +
					    '<div tabindex="0" role="button" class="sb__form-field-input sb-custom-box-shadow-color sb-custom-box-shadow-color-hover sb-custom-box-shadow-color-focus sb-custom-field-bg-color">' +
						    '<%this._renderDateField(this._currentValue.checkin, "CheckinDate")%>' +
					    "</div>" +
					"</div>" +
					'<div id="<%this._o.FieldIds.Checkout%>" class="sb__form-field sb__form-field--checkout">' +
                        '<%if (!this._o.HideFieldLabels){%><span class="sb__form-field-label sb-custom-label-color"><%this._o.Localizations.Labels["CheckoutDate"][this._o.CodLang]%></span><%}%>' +
					    '<div tabindex="0" role="button" class="sb__form-field-input sb-custom-box-shadow-color sb-custom-box-shadow-color-hover sb-custom-box-shadow-color-focus sb-custom-field-bg-color">' +
						    '<%this._renderDateField(this._currentValue.checkout, "CheckoutDate")%>' +
					    "</div>" +
					"</div>" +
				"</div>" +
				'<div class="sb__guests-rooms">' +
					'<div class="sb__form-field">' +
						'<%if (!this._o.HideFieldLabels){%><span class="sb__form-field-label sb-custom-label-color"><%this._o.Localizations.Labels.NumPersons[this._o.CodLang]%></span><%}%>' +
						'<div id="<%this._o.FieldIds.Guests%>" tabindex="0" role="button" aria-pressed="false" class="sb__form-field-input sb-custom-box-shadow-color sb-custom-box-shadow-color-hover sb-custom-box-shadow-color-focus sb-custom-field-bg-color">' +
							"<%this._renderGuestsField()%>" +
						"</div>" +
					"</div>" +
				"</div>" +
				'<input id="<%this._o.FieldIds.AvailabilityButton%>" type="button" value="<%this._o.Localizations.Labels.CheckAvailability[this._o.CodLang]%>" class="sb__btn sb__btn--block sb__btn--verify sb-custom-button-color sb-custom-button-bg-color sb-custom-button-hover-bg-color" />' +
			"</div>" +
			'<div class="sb__footer">' +
				'<div class="sb__footer-actions">' +
					'<div class="sb__footer-promo-wrapper">' +
						'<a tabindex="-1" id="<%this._o.FieldIds.Promo%>" href="#" class="sb__footer-link sb__footer-link--promo sb-custom-link-color sb-custom-color-hover">' +
							"<%this._renderPromoField()%>" +
						"</a>" +
					"</div>" +
                    "<%if(!this._o.Properties){%>" +
                        //'<a href="<%this._o.Addresses.HttpHost%>/ibe/reservations/edit?hid=<%this._o.HotelId%>&lang=<%this._o.CodLang%>" target="_blank" class="sb__footer-link sb__footer-link--edit sb-custom-link-color sb-custom-color-hover">' +
                        '<a tabindex="-1" href="#" id="<%this._o.FieldIds.ReservationEditLink%>" target="_blank" class="sb__footer-link sb__footer-link--edit sb-custom-link-color sb-custom-color-hover">' +
						    '<svg class="icon sb-custom-icon-color">' +
							    '<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#edit"></use>' +
						    "</svg>" +
						    "<%this._o.Localizations.Labels.ModCancReservation[this._o.CodLang]%>" +
					    "</a>" +
                    "<%}%>" +
				"</div>" +
			"</div>" +
            "<%if(this.WaitForGA4){%>" +
            "<form action=\"<%this._renderBookingVersionEndpoint()%>\" id=\"<%this._o.FieldIds.HiddenSearchForm%>\" method=\"get\" rel=\"noopener\" target=\"_blank\" style=\"opacity: 0; height: 0; width: 0;\">" +
            "</form>"+
            "<%}%>"
            ;

        self._onAvailabilityRequest = function (e) {
            self.guestsSelector._onClick();
            e = e || window.event;
            var target = e.target || e.srcElement;

            if (!target) {
                return;
            }

            if (!self._o.PortalId && !self._currentValue.property.id) {
                return self._o.onNoPropertySelected();
            }

            var url = self._buildUrl();

            if (self.WaitForGA4 && self.hiddenForm) {
                self._postFormForGA4(url);
                return;
            }

            self._goToBooking(url);
        };

        self._onReservationEdit = function(e) {
            e = e || window.event;
            e.preventDefault();
            var target = e.target || e.srcElement;

            if (!target) {
                return;
            }

            let url = self._o.UseIbe2
                ? "<%this._o.Addresses.HttpHost%>/ibe2/hotel/<%this._o.HotelId%>?lang=<%this._o.CodLang%>&returnUrl=/ibe2/hotel/<%this._o.HotelId%>/personal-area/reservations&auth_modal=res"
                : "<%this._o.Addresses.HttpHost%>/ibe/reservations/edit?hid=<%this._o.HotelId%>&lang=<%this._o.CodLang%>";

            url += self._getGA4LinkParams();
            const properUrl = sbBase.TemplateEngine(url, self);

            if (self.WaitForGA4 && self.hiddenForm) {
                self._postFormForGA4(properUrl);
                return;
            }

            self._goToBooking(properUrl);
        };

        self._getGA4LinkParams = function() {
            if (self.GA4ClientId && self.GA4SessionId) {
                return "&GA4CliId=" + self.GA4ClientId + "&GA4SesId=" + self.GA4SessionId;
            }
            if (self.GA4LinkerParams) {
                return "&_gl=" + self.GA4LinkerParams;
            }

            return "";
        };

        self._customParamsDecorator = function() {
            try {
                return self._o.customParamsDecorator();
            } catch(e) {
                return "";
            }
        };

        self._GetBookingVersionEndpoint = function () {
            return this._o.UseIbe2
                ? "<%this._o.Addresses.HttpHost%>" + (
                    this._o.PortalId
                        ? "/portal/<%this._o.PortalId%>?"
                        : "/ibe2/hotel/<%this._currentValue.property.id%>?"
                )
                : "<%this._o.Addresses.HttpHost%>" + (
                    this._o.PortalId 
                        ? "/ibe/portal?pid=<%this._o.PortalId%>&"
                        : "/ibe/search?hid=<%this._currentValue.property.id%>&"
                )
                ;
        };
        self._GetBaseParams = function(GA4Ids, customParams) {
            var route = this._o.PortalId 
                ? this._currentValue.property.id && !this._currentValue.property.placeId ? "q" : "p" 
                : "q";

            return "lang=<%this._o.CodLang%>" +
                "&cur=<%this._o.Currency%>" +
                "<%if(this._o.PortalTemplateId){%>" +
                "&tid=<%this._o.PortalTemplateId%>" +
                "<%}%>"+
                "<%this._o.GetCustomQueryStringParams()%>" +
                GA4Ids + customParams +
                (this._o.UseIbe2 ? "" : "#/" + route);
        };
        self._GetSearchParams = function() {
            return "&guests=<%this._currentValue.guestAllocation%>" +
                '&in=<%this._currentValue.checkin.getFullYear() +"-"+ (this._currentValue.checkin.getMonth()+1+"").padStart(2, "0") +"-"+ (this._currentValue.checkin.getDate() + "").padStart(2, "0")%>' +
                '&out=<%this._currentValue.checkout.getFullYear() +"-"+ (this._currentValue.checkout.getMonth()+1+"").padStart(2, "0") +"-"+ (this._currentValue.checkout.getDate() + "").padStart(2, "0")%>' +
                "&coupon=<%this._currentValue.promoCode%>" +
                "<%if(this._o.PortalId){%>" +
                "&hid=<%this._currentValue.property.id%>" +
                "&placeId=<%this._currentValue.property.placeId%>" +
                "<%}%>" +
                "<%if(this._o.UseMobile()){%>" +
                "&REFCODE=MOBILESITE&MOBILEURL=<%this._o.HomesiteUrl%>" +
                "<%}%>";
        };
        self._postFormForGA4 = function (buildedUrl) {
            // Forced Google Linker decorators to decorate forms and revert them back after submit
            // Inspired by: https://www.thyngster.com/cross-domain-tracking-on-google-analytics-4-ga4/
            let oldDecoratorFormsSettings = [];
            if(window.google_tag_data && window.google_tag_data.gl.decorators && window.google_tag_data.gl.decorators.length > 0){
                for (let i = 0, l = window.google_tag_data.gl.decorators.length; i < l; i++) {
                    oldDecoratorFormsSettings.push(window.google_tag_data.gl.decorators[i].forms);
                    window.google_tag_data.gl.decorators[i].forms = !0;
                }
            }

            self.hiddenForm.action = buildedUrl;
            while (self.hiddenForm.lastElementChild) {
                self.hiddenForm.removeChild(self.hiddenForm.lastElementChild);
            }
            const url = new URL(buildedUrl);
            const urlSearchParams = new URLSearchParams(url.search);
            const params = Object.fromEntries(urlSearchParams.entries());
            for (const prop in params) {
                if (!prop.startsWith("GA4")) {
                    let input = document.createElement("input");
                    input.setAttribute("type", "hidden");
                    input.setAttribute("id", self.hiddenForm.id + "_" + prop);
                    input.setAttribute("name", prop);
                    input.setAttribute("value", params[prop]);
                    self.hiddenForm.appendChild(input);
                }
            }
            self.hiddenForm.submit();
            if (oldDecoratorFormsSettings.length > 0) {
                for (let i = 0, l = oldDecoratorFormsSettings.length; i < l; i++) {
                    window.google_tag_data.gl.decorators[i].forms = oldDecoratorFormsSettings[i];
                }
            }
        };
        self._buildUrl = function () {

            var GA4Ids = this._getGA4LinkParams();
            var customParams = this._customParamsDecorator();

            var url = this._GetBookingVersionEndpoint() +
                        this._GetBaseParams(GA4Ids, customParams) + 
                        this._GetSearchParams();

            return sbBase.TemplateEngine(url, this);
        };

        self._goToBooking = function (url) {
            var self = this;
            if (self._o.UseGoogleAnalyticsIntegration) {
                url = self.getUrlWithGALinker(url);
            }
            if (!self._o.OpenInNewWindow) { top.location = url; }
            else { window.open(url); }
        };

        self._renderDateField = function (date, label) {
            var m = this.getMonth(date);
            var tmplModel = {
                hideFieldLabels: this._o.HideFieldLabels,
                label: this._o.Localizations.Labels[label][this._o.CodLang],
                date: date.getDate(),
                month: this.getMonth(date),
                weekDay: this.getWeekDay(date),
                year: date.getFullYear()
            };
            return sbBase.TemplateEngine(this._o.Templates.Date, tmplModel);
        };

        self._renderGuestsField = function () {
            var tmplModel = {
                adults: this._currentValue.guests.totalAdults,
                adultsLabel: this._o.Localizations.Labels.NumAdults[this._o.CodLang],
                children: this._currentValue.guests.totalKids,
                childrenLabel: this._o.Localizations.Labels.NumKids[this._o.CodLang],
                rooms: this._currentValue.guests.totalRooms,
                roomsLabel: this._o.Localizations.Labels.NumRooms[this._o.CodLang],
            };
            return sbBase.TemplateEngine(this._o.Templates.Guests, tmplModel);
        };
        
        self._renderPropertyField = function () {
            var currentProperty = this._currentValue.property;
            if (currentProperty.localizedNames) {
                currentProperty.name = currentProperty.localizedNames[this._o.CodLang.toLowerCase()] ||
                    currentProperty.localizedNames[this._o.DefaultLang.toLowerCase()] ||
                    currentProperty.name;
                console.log(currentProperty);
            }
            return sbBase.TemplateEngine(this._o.Templates.Property, currentProperty);
        };

        self._renderPromoField = function () {
            return sbBase.TemplateEngine(this._o.Templates.Promo, this);
        };

        self._renderBookingVersionEndpoint = function() {
            return sbBase.TemplateEngine(this._GetBookingVersionEndpoint(), this);
        };

        self._onStartEditing = function (curEl) {
            self._editingElement = curEl;
            self._setOpenBottomTop();
            setTimeout(function () {
                sbUtils.addClass(self.formNode, "editing", true);
            }, 10);
        };

        self._onEndEditing = function () {
            self._editingElement = null; 
            sbUtils.removeClass(self.formNode, "editing");
        };

        self._getNumberOfMonths = function () {
            return sbUtils.hasClass(self.el, "sb-screen-m") ? self._o.NumberOfMonths : self._o.NumberOfMonthsVertical;
        };

        self._initWidgets = function () {

            self.availabilityInput = document.getElementById(self._o.FieldIds.AvailabilityButton);
            self.reservationEditLink = document.getElementById(self._o.FieldIds.ReservationEditLink);
            self.formNode = document.getElementById(self._o.FieldIds.Form);
            self.propertyNode = document.getElementById(self._o.FieldIds.Property);
            self.checkinNode = document.querySelector('#' + self._o.FieldIds.Checkin + " .sb__form-field-input");
            self.checkoutNode = document.querySelector('#' + self._o.FieldIds.Checkout + " .sb__form-field-input");
            self.guestsNode = document.getElementById(self._o.FieldIds.Guests);
            self.promoNode = document.getElementById(self._o.FieldIds.Promo);

            self.hiddenForm = document.getElementById(self._o.FieldIds.HiddenSearchForm);
            
        /* property selector widget */
            if (this._o.Properties && this._o.Properties.length) {
                this.propertySelector = new PropertySelector({
                    trigger: self.propertyNode,
                    property: self._currentValue.property,
                    properties: self._o.Properties,
                    onSelect: function (property) {
                        self.setSelectedProperty(property);
                        self.propertyNode.innerHTML = self._renderPropertyField();
                    },
                    onOpen: function () { self._onStartEditing(self.propertyNode); },
                    onClose: self._onEndEditing,
                    confirmOnBlur: true,
                    lang: self._o.CodLang.toLowerCase(),
                    defaultLang: self._o.DefaultLang.toLowerCase()
                });
            }
            /* end promo code widgets */

            /*calendar widget*/
            self.dateRangePicker = new Pikaday({
                container: self.checkinNode.parentNode,
                field: self.checkinNode,
                endField: self.checkoutNode,
                minDate: self._o.MinDate ? new Date(self._o.MinDate) : self._currentValue.checkin,
                maxDate: new Date(2100, 12, 31),
                firstDay: self._o.Localizations.SundayFirst[self._o.CodLang] ? 0 : 1,
                checkInDays: self._o.CheckInDays,
                selectedRange: {
                    start: self._currentValue.checkin,
                    end: self._currentValue.checkout
                },
                defaultDate: self._currentValue.checkin,
                minRangeLength: self._o.MinStay,
                numberOfMonths: self._getNumberOfMonths(),
                i18n: {
                    months: self._o.Localizations.FullMonth[self._o.CodLang].length ? self._o.Localizations.FullMonth[self._o.CodLang] : self._o.Localizations.FullMonth[self._o.DefaultLang],
                    weekdaysShort: self._o.Localizations.SmallDay[self._o.CodLang].length ? self._o.Localizations.SmallDay[self._o.CodLang] : self._o.Localizations.SmallDay[self._o.DefaultLang],
                },
                onSelect: function (range) {
                    self.setDateRange(range);
                    self.checkinNode.innerHTML = self._renderDateField(self._currentValue.checkin, "CheckinDate");
                    self.checkoutNode.innerHTML = self._renderDateField(self._currentValue.checkout, "CheckoutDate");

                    sbUtils.handleKeyDown(".sb__dates div[role='button']");
                },
                onOpen: function () { self._onStartEditing(self.checkinNode); },
                onClose: self._onEndEditing,
            });
            /* end calendar widget*/

            /* guests widgets */
            self.guestsSelector = new GuestsSelector({
				    trigger: self.guestsNode,
                    nextTab: self.promoNode,
				    selectedGuests: self._currentValue.guestAllocation,
				    i18n: {
				        room: self._o.Localizations.Labels.RoomAllocation[self._o.CodLang],
				        adult: self._o.Localizations.Labels.NumAdults[self._o.CodLang],
				        adults: self._o.Localizations.Labels.NumAdults[self._o.CodLang],
				        kid: self._o.Localizations.Labels.NumKids[self._o.CodLang],
				        kids: self._o.Localizations.Labels.NumKids[self._o.CodLang],
                        age: self._o.Localizations.Labels.KidAge[self._o.CodLang],
                        add: self._o.Localizations.Labels.Add[self._o.CodLang],
				        addRoom: self._o.Localizations.Labels.AddRoom[self._o.CodLang],
				        cancel: self._o.Localizations.Labels.Cancel[self._o.CodLang],
				        confirm: self._o.Localizations.Labels.Confirm[self._o.CodLang],
				    },
                    onSelect: function (guests) {
                        var wasEditing = self._editingElement == self.guestsNode;
				        self.setGuests(guests);
				        self.guestsNode.innerHTML = self._renderGuestsField();
                        self._onEndEditing();

                        if (wasEditing) {
                            self.guestsNode.focus();
                        }
				    },
				    onOpen: function () { self._onStartEditing(self.guestsNode); },
				    confirmOnBlur: true,
				    maxRooms: self._o.MaxRooms,
				    maxAdults: self._o.MaxAdults,
				    maxKids: self._o.MaxKids,
				    minKidAge: self._o.MinKidsAge,
				    maxKidAge: self._o.MaxKidsAge
            });
            self.guestsSelector.validate();
            /* end guests widgets */

            /* promo code widget */
            var promoCodeSelector = new PromoCodeSelector({
                trigger: self.promoNode,
                promoCode: self._currentValue.promoCode,
                i18n: {
                    inputLabel: self._o.Localizations.Labels.PromoInsert[self._o.CodLang],
                    inputPlaceholder: self._o.Localizations.Labels.PromoCode[self._o.CodLang],
                    confirm: self._o.Localizations.Labels.Confirm[self._o.CodLang],
                    cancel: self._o.Localizations.Labels.Cancel[self._o.CodLang]
                },
                onSelect: function (promoCode) {
                    self.setPromoCode(promoCode);
                    self.promoNode.innerHTML = self._renderPromoField();
                    self.promoNode.focus();
                },
                onOpen: function () { self._onStartEditing(self.promoNode); },
                onClose: self._onEndEditing,
                confirmOnBlur: true
            });
            /* end promo code widgets */

            sbUtils.addEvent(self.availabilityInput, "click", this._o.OnAvailabilityRequest || self._onAvailabilityRequest, true);
            sbUtils.addEvent(self.reservationEditLink, "click", this._o._onReservationEdit || self._onReservationEdit, true);
            this.setupFocusNavigation();
        };

        self.setupFocusNavigation = function () {
            sbUtils.setFocusNavigation(self.guestsNode, null, self.promoNode, function () {
                return self._editingElement != self.guestsNode;
            });
            sbUtils.setFocusNavigation(self.promoNode, self.guestsNode, self.reservationEditLink, function () {
                return self._editingElement != self.promoNode;
            });
            sbUtils.setFocusNavigation(self.reservationEditLink, self.promoNode, self.availabilityInput);
            sbUtils.setFocusNavigation(self.availabilityInput, self.reservationEditLink, null);
        },

        /* rendering utility functions */
        self.getMonth = function (date) {
            return (
				this._o.Localizations.FullMonth[this._o.CodLang][date.getMonth()] ||
				this._o.Localizations.FullMonth[this._o.DefaultLang][date.getMonth()]
				);
        };
        self.getWeekDay = function (date) {
            return (
				this._o.Localizations.FullDay[this._o.CodLang][date.getDay()] ||
				this._o.Localizations.FullDay[this._o.DefaultLang][date.getDay()]
				);
        };
        /**/

        /*GA tracker*/
        self.getGATracker = function (trackerName, gaId) {
            var tracker = null;
            var idsIndex = 0;
            var gaIds = gaId.split(",");
            // Must be checked with new version of GA
            if (!tracker && window.ga && ga.loaded) {
                try { tracker = ga.getByName(trackerName); } catch (e) { }
                if (!tracker && window.gtag) {
                    while (idsIndex < gaIds.length && !tracker) {
                        try { tracker = ga.getByName(("gtag_" + gaIds[idsIndex]).replace(/\-/gi, "_")); } catch (e) { }
                        idsIndex++;
                    }
                }
            }
            if (!tracker && window._gaq) {
                try { tracker = window._gaq._getAsyncTracker(); } catch (e) { }
            }
            return tracker;
        };
        self.getGALinkerUrl = function (tracker, url) {
            if (tracker._getLinkerUrl) {
                return tracker._getLinkerUrl(url);
            }
            if (tracker.get) {
                var linker = new window.gaplugins.Linker(tracker);
                return linker.decorate(url);
            }
            return url;
        };
        self.getUrlWithGALinker = function(url) {
            var SBPageTracker = self.getGATracker(self._o.GAPageTrackerName, self._o.GoogleAnalyticsId);
            if (SBPageTracker) {
                try {
                    return self.getGALinkerUrl(SBPageTracker, url);
                } catch (e) {
                    console.log(e);
                    return url;
                }
            }
            return url;
        },
        self.getCookie = function(name) {
          var match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
          if (match) return match[2];
        },
        self.getUrlWithGA4Data = function() {
            if (!window.gtag) {
                return null;
            }
            var gaIds = self._o.GoogleAnalyticsId.split(",");
            for (var i = 0, l = gaIds.length; i < l; i++) {
                if (gaIds[i].indexOf("G-") === 0) {

                    window.gtag('config', gaIds[i], { 'linker': { 'decorate_forms': true } });

                    self.WaitForGA4 = true;
                    window.gtag("get", gaIds[i], "client_id", (client_id) => {
                        self.GA4ClientId = client_id;
                    });
                    window.gtag("get", gaIds[i], "session_id", (session_id) => {
                        self.GA4SessionId = session_id;
                    });
                    break;
                }
            }
            return null;
        },
        /* end GA tracker*/
        self._getStyleSheet = function () {
            var style = document.createElement("style");
            document.body.appendChild(style); // must append before you can access sheet property
            return style.sheet;
        };

        /*styles functions*/
        self._fixStyles = function () {
            var stylesheet = self._getStyleSheet();
            if (!stylesheet)
                return;
            for (var p in self._o.Styles.CustomStyleMappings) {
                var customValue = this._o.Styles[p];
                if (self._o.Styles.CustomStyleMappings.hasOwnProperty(p) && customValue) {
                    var customStyleTemplates = self._o.Styles.CustomStyleMappings[p];
                    if (!sbUtils.isArray(customStyleTemplates))
                        customStyleTemplates = [customStyleTemplates];

                    customStyleTemplates.forEach(function (tmpl) {
                        stylesheet.insertRule("#" + self._o.MainContainerId + " " + sbBase.TemplateEngine(tmpl, { value: customValue, _colorToRgba: self._colorToRgba }), 0);
                    });
                }
            }
        };
        self.isHex = function (h) {
            var a = parseInt(h, 16);
            return (a.toString(16) === h.toLowerCase());
        };

        self._colorToRgba = function (color, a) {
            if (color.substr(0, 3) !== "rgb" && window.getComputedStyle) {//cannot recognize rgb color
                var d = document.createElement("div");
                d.style.color = color;
                document.body.appendChild(d);
                color = window.getComputedStyle(d, null).getPropertyValue("color");
                document.body.removeChild(d);
            }
            return color.substr(0, 3) !== "rgb" ? color : "rgba(" + color.substr(4, color.length - 5) + "," + a + ")";
        };

        self._setElementClasses = function () {
            var elClass = "sb sb-custom-color sb-custom-bg-color";
            var mediaQueries = self._o.Styles.PseudoMediaQueries;
            for (var p in mediaQueries) {
                if (!mediaQueries.hasOwnProperty(p))
                    continue;
                if (self.mainContainer.offsetWidth > p)
                    elClass += " " + mediaQueries[p];
            }

            if (self._o.Properties && self._o.Properties.length > 1)
                elClass += " has-multi-property";

            if (self._o.Styles.Footer && self._o.Styles.Footer.ShowInline)
                elClass += " footer-inline";

            elClass += self._setOpenBottomTop();

            if (self._o.HideFieldLabels)
                elClass += " no-labels";

            elClass += " sb-direction-" + (self._o.CodLang === "HE" ? "rtl" : "ltr");
            
            self.el.className = elClass;

            if (self._getNumberOfMonths() > 1 && self.mainContainer) {
                sbUtils.addClass(self.el, "number-of-months-vertical");
                var hardCoded2MonthsWidth = 700;
                var rect = self.mainContainer.getBoundingClientRect();
                var fitsOnTheRight = window.innerWidth - rect.left - hardCoded2MonthsWidth >= 0;
                var fitsOnTheLeft = rect.right - hardCoded2MonthsWidth >= 0;
                if (fitsOnTheRight) {
                    sbUtils.addClass(self.el, "number-of-months-vertical--left");
                } else if (fitsOnTheLeft) {
                    sbUtils.addClass(self.el, "number-of-months-vertical--right");
                }
            }

            self.dateRangePicker && self.dateRangePicker.setNumberOfMonths(self._getNumberOfMonths());
        };

        self._setOpenBottomTop = function () {
            var curEl = self._editingElement;
            if (curEl) {
                var rect = curEl.getBoundingClientRect();
                var bottomSpace = window.innerHeight - rect.top;
                var openTopClass = "sb-open-top";
                if (rect.top > bottomSpace) {
                    sbUtils.addClass(self.el, openTopClass);
                    return " " + openTopClass;
                } else {
                    sbUtils.removeClass(self.el, openTopClass);
                }
            }
            return "";
        };

        /* end styles functions*/

        self._createSearchAvailabilityIframe = function () {
            var model = {
                containerId: this._o.FieldIds.AvailabilityFormContent,
                iframeContent: this._createSearchAvailabilityIframeOnly()
            }
            return sbBase.TemplateEngine(this._o.Templates.AvailabilityPopoverContent, model);
        };

        self._createSearchAvailabilityIframeOnly = function () {
            var iframeSrc = this._o.Addresses.ConvertoHost + "/customerrequest?hid=" + self._currentValue.property.id
                + "&lang=" + self._o.CodLang
                + "&showLoadingAfterSave=" + (self._o.Converto.ThankYouPage ? "true" : "false")
                + "&manualLoading=true"
                + this._getGA4LinkParams()
                + this._customParamsDecorator()
                ;
            
            if (self._o.UseGoogleAnalyticsIntegration) {
                iframeSrc = self.getUrlWithGALinker(iframeSrc);
            }

            var model = {
                iframeSrc: iframeSrc
            }
            return sbBase.TemplateEngine(this._o.Templates.IFrameContent, model);
        };

        self.mainContainer = document.getElementById(self._o.MainContainerId);
        if (!self.mainContainer) {
            console.log("no container for calendar");
            return;
        }
        self.el = document.createElement("div");
        self.mainContainer.innerHTML = "";
        self.mainContainer.appendChild(self.el);
        self._setElementClasses();
        sbUtils.addEvent(window, "resize", self._setElementClasses, true);
        sbUtils.addEvent(window, "scroll", self._setElementClasses, true);

        var svg = document.createElement("div");
        svg.innerHTML = self._o.Styles.Svg;
        document.body.insertBefore(svg, document.body.firstChild);
    };



    /**
     * public SearchBox API
     */
    SearchBox.prototype = {

        /**
         * configure functionality
         */
        config: function(options) {
            if (!this._o) {
                this._o = sbUtils.extend({}, defaults, true);
            }

            if (options.Properties && options.Properties.length > 1) {
                this._o.Styles.PseudoMediaQueries[900] = this._o.Styles.PseudoMediaQueries[720];
                this._o.Styles.PseudoMediaQueries[720] = null;
            }

            var opts = sbUtils.extend(this._o, options, true);

            /*Labels must be read even if not inside Localizations*/
            if (options.Labels)
                sbUtils.extend(this._o, { Localizations: { Labels: options.Labels } }, true);

            opts.Checkin = opts.Checkin ? new Date(opts.Checkin) : sbUtils.addDays(new Date(), opts.ReleaseDays);
            opts.Checkout = opts.Checkout ? new Date(opts.Checkout) : sbUtils.addDays(opts.Checkin, opts.MinStay);
            opts.MaxRooms = Math.min(opts.MaxRooms, opts.TotRoomsHotel);
            opts.MaxAdults = opts.Use12PersonLimit ? 12 : opts.MaxAdults;

            for (var fid in opts.FieldIds) {
                if (opts.FieldIds.hasOwnProperty(fid)) {
                    opts.FieldIds[fid] = opts.MainContainerId + "_" + opts.FieldIds[fid];
                }
            }

            var applyDefaultLang = function(localization, lang, defLang) {
                for (var l in localization) {
                    if (localization.hasOwnProperty(l) && l != "SundayFirst") {
                        if (!localization[l][opts.CodLang] && localization[l][opts.DefaultLang]) {
                            localization[l][opts.CodLang] = localization[l][opts.DefaultLang];
                        }
                    }
                }
            };
            applyDefaultLang(opts.Localizations.Labels, opts.CodLang, opts.DefaultLang);
            applyDefaultLang(opts.Localizations, opts.CodLang, opts.DefaultLang);

            var currentProperty = { id: opts.HotelId, name: "HOTEL NAME" };
            if (opts.Properties && opts.Properties.length) {
                opts.PortalId &&
                    opts.Properties.unshift({ id: 0, name: opts.Localizations.Labels.AllProperties[opts.CodLang] });
                var inputProperty = opts.HotelId
                    ? sbUtils.toMap(sbUtils.flatten(opts.Properties, "children"))[opts.HotelId]
                    : null;
                currentProperty = inputProperty || opts.Properties[0];
            }

            var currentAllocation = "A,A";
            if (opts.DefaultPersons) {
                var persons = [];
                for (var i = 0; i < opts.DefaultPersons; i++) {
                    persons.push("A");
                }
                currentAllocation = persons.join(",");
            }
            if (opts.GuestAllocation) {
                currentAllocation = opts.GuestAllocation;
            }

            this._currentValue = {
                property: currentProperty,
                checkin: opts.Checkin,
                checkout: opts.Checkout,
                guests: {
                    totalAdults: opts.DefaultPersons,
                    totalKids: 0,
                    totalRooms: 1
                },
                guestAllocation: currentAllocation,
                promoCode: opts.PromoCode
            }

            var customColors = opts.Styles.Themes[opts.Styles.Theme] || {};
            sbUtils.extend(opts.Styles, customColors, false);

            return opts;
        },

        init: function (force) {
            this.getUrlWithGA4Data();
            this.renderIframeInPage();
            /*if(this._initialized && !force && !this._o.AutoLoad)
				return;*/
            if (!this.el)
                return;

            this._fixStyles();
            this.draw(force);
            this._initWidgets();
            this._initialized = true;
            if (this._o.AfterInitCallBack) {
                this._o.AfterInitCallBack();
            }
        },

        /**
         * refresh the HTML
         */
        draw: function(force) {
            if (this._initialized && !force) {
                return;
            }

            this.el.innerHTML = sbBase.TemplateEngine(this.template, this);
            sbUtils.handleKeyDown(".sb__guests-rooms div[role='button']");
            sbUtils.handleKeyDown(".sb__property div[role='button']");

            if (typeof this._o.onDraw === "function") {
                this._o.onDraw(this);
            }
        },

        setSelectedProperty: function(property, refresh) {
            this._currentValue.property = property;
            if (refresh) {
                this.propertySelector.setPropertyById(this._currentValue.property.id, false);
            }
        },

        setDateRange: function(range) {
            this._currentValue.checkin = range.start;
            this._currentValue.checkout = range.end;
        },

        setGuests: function(guests) {
            this._currentValue.guestAllocation = guests.toString();
            this._currentValue.guests.totalAdults = guests.totalAdults();
            this._currentValue.guests.totalKids = guests.totalKids();
            this._currentValue.guests.totalRooms = guests.totalRooms();
        },

        setPromoCode: function(promoCode) {
            this._currentValue.promoCode = promoCode;
        },

        openSB: function(lang, hotelId) {
            const url = (this._o.UseIbe2 
                    ? "<%this.host%>/ibe2/hotel/<%this.hotelId%>?"
                    : "<%this.host%>/ibe/search?hid=<%this.hotelId%>&" 
                ) +
                "lang=<%this.codLang%>" +
                this._getGA4LinkParams() + 
                this._customParamsDecorator() +
                "<%this.customParams%>";
            const urlModel = {
                host: this._o.Addresses.HttpHost,
                hotelId: hotelId || this._currentValue.property.id,
                codLang: lang || this._o.CodLang,
                customParams: this._o.GetCustomQueryStringParams()
            };

            const properUrl = sbBase.TemplateEngine(url, urlModel);

            if (this.WaitForGA4 && this.hiddenForm) {
                this._postFormForGA4(properUrl);
                return;
            }

            this._goToBooking(properUrl);
        },

        getSearchValues: function() {
            return this._currentValue;
        },

        renderIframeInPage: function() {
            if (this.WaitForGA4 && !this.GA4ClientId && !this.GA4SessionId){
                setTimeout(() => {this.renderIframeInPage();}, 50);
                return;
            }
            if (!this._o.Converto.InPageContainerId) {
                console.log("Converto.InPageContainerId not set. Cannot render form");
                return -1;
            }
            var iframeContainer = document.getElementById(this._o.Converto.InPageContainerId);
            if (!iframeContainer) {
                console.log("Cannot find div with id " + this._o.Converto.InPageContainerId);
                return -1;
            }
            var iframeHtml = this._createSearchAvailabilityIframeOnly();
            iframeContainer.innerHTML = iframeHtml;

            var iframe = document.querySelector("#" + this._o.Converto.InPageContainerId + " iframe");
            this.registerHandleMessages(iframe, null, this.onFormSubmitSuccess.bind(this));
        },

        onFormSubmitSuccess: function() {
            if (this._o.Converto.OnFormSubmitSuccess) {
                this._o.Converto.OnFormSubmitSuccess();
            } else if (this._o.Converto.ThankYouPage) {
                window.location.href = this._o.Converto.ThankYouPage;
            }
        },

        showAvailabilityForm: function(options) {
            if (!window.SBModal) {
                return console.error("SBModal not defined. Module ADVANCED_BOOKBACK must be enabled");
            }

            if (!this.availabilityPopup) {
                this.availabilityPopup = new SBModal(sbUtils.extend({
                        i18n: {
                            title: this._o.Converto.Labels.PopoverTitle[this._o.CodLang]
                        },
                        keepContent: true
                    },
                    options,
                    true));
            }

            var popoverHtml = this._createSearchAvailabilityIframe();

            this.availabilityPopup.setContent(popoverHtml);

            if (this.handleMessage) {
                window.removeEventListener("message", this.handleMessage);
            }
            var self = this;
            var onLoaded = function() {
                var popoverContent = document.getElementById(self._o.FieldIds.AvailabilityFormContent);
                sbUtils.addClass(popoverContent, "loaded");
            };
            var iframe = document.querySelector("#" + this._o.FieldIds.AvailabilityFormContent + " iframe");
            this.registerHandleMessages(iframe, onLoaded, this.onFormSubmitSuccess.bind(this));
            this.availabilityPopup.show();
        },

        registerHandleMessages: function (iframe, onLoaded, onSuccess) {
            var self = this;
            this.handleMessage = function (event) {
                var message = event.data;
                if (!message || !message.code) {
                    return;
                }
                if (message.code === "loaded") {
                    onLoaded && onLoaded();
                    iframe && (iframe.style.height = message.contentHeight + "px");
                } else if (message.code === "ready") {
                    var styles = sbUtils.extend({}, self._o.Styles);
                    styles = sbUtils.extend(styles, self._o.Converto.Styles || {}, true);
                    var configMessage = {
                        code: "availabilityFormConfig",
                        config: {
                            Styles: styles,
                            Labels: self._o.Converto.Labels,
                            Name: self._o.ConvertoFormName || self._o.Converto.FormName,
                            Checkin: self._currentValue.checkin.toDateString(),
                            Checkout: self._currentValue.checkout.toDateString(),
                            GuestAllocation: self._currentValue.guestAllocation,
                            MaxRooms: self._o.Converto.MaxRooms || self._o.MaxRooms,
                            MaxAdults: self._o.Converto.MaxAdults || self._o.MaxAdults,
                            MaxKids: self._o.Converto.MaxKids || self._o.MaxKids,
                            MinKidsAge: self._o.Converto.MinKidsAge || self._o.MinKidsAge,
                            MaxKidsAge: self._o.Converto.MaxKidsAge || self._o.MaxKidsAge,
                            AskNewsletterSubscription: self._o.Converto.AskNewsletterSubscription,
                            AdditionalRequiredFields: self._o.Converto.AdditionalRequiredFields
                        }
                    }
                    event.source.postMessage(configMessage, "*");
                } else if (message.code === "success" && onSuccess) {
                    onSuccess();
                }
            };
            window.addEventListener("message", this.handleMessage);
        },

        isValidAllocation: function() {
            return this.guestsSelector.isValidAllocation();
        }

    };

    return SearchBox;

}));

;
!function (e, o) { "object" == typeof exports && "undefined" != typeof module ? module.exports = o() : "function" == typeof define && define.amd ? define(o) : e.MicroModal = o() }(this, function () {
    "use strict"
    var e = function (e, o) { if (!(e instanceof o)) throw new TypeError("Cannot call a class as a function") }, o = function () {
        function e(e, o) {
            for (var t = 0; t < o.length; t++) {
                var i = o[t]
                i.enumerable = i.enumerable || !1, i.configurable = !0, "value" in i && (i.writable = !0), Object.defineProperty(e, i.key, i)
            }
        } return function (o, t, i) { return t && e(o.prototype, t), i && e(o, i), o }
    }(), t = function (e) {
        if (Array.isArray(e)) {
            for (var o = 0, t = Array(e.length); o < e.length; o++)t[o] = e[o]
            return t
        } return Array.from(e)
    }
    return function () {
        var i = ["a[href]", "area[href]", 'input:not([disabled]):not([type="hidden"]):not([aria-hidden])', "select:not([disabled]):not([aria-hidden])", "textarea:not([disabled]):not([aria-hidden])", "button:not([disabled]):not([aria-hidden])", "iframe", "object", "embed", "[contenteditable]", '[tabindex]:not([tabindex^="-"])'], n = function () {
            function n(o) {
                var i = o.targetModal, a = o.triggers, r = void 0 === a ? [] : a, s = o.onShow, l = void 0 === s ? function () { } : s, c = o.onClose, d = void 0 === c ? function () { } : c, u = o.openTrigger, f = void 0 === u ? "data-micromodal-trigger" : u, h = o.closeTrigger, v = void 0 === h ? "data-micromodal-close" : h, g = o.disableScroll, m = void 0 !== g && g, b = o.disableFocus, y = void 0 !== b && b, w = o.awaitCloseAnimation, k = void 0 !== w && w, p = o.debugMode, E = void 0 !== p && p
                e(this, n), this.modal = document.getElementById(i), this.config = { debugMode: E, disableScroll: m, openTrigger: f, closeTrigger: v, onShow: l, onClose: d, awaitCloseAnimation: k, disableFocus: y }, r.length > 0 && this.registerTriggers.apply(this, t(r)), this.onClick = this.onClick.bind(this), this.onKeydown = this.onKeydown.bind(this)
            } return o(n, [{
                key: "registerTriggers", value: function () {
                    for (var e = this, o = arguments.length, t = Array(o), i = 0; i < o; i++)t[i] = arguments[i]
                    t.forEach(function (o) { o.addEventListener("click", function () { return e.showModal() }) })
                }
            }, { key: "showModal", value: function () { this.activeElement = document.activeElement, this.modal.setAttribute("aria-hidden", "false"), this.modal.classList.add("is-open"), this.setFocusToFirstNode(), this.scrollBehaviour("disable"), this.addEventListeners(), this.config.onShow(this.modal) } }, {
                key: "closeModal", value: function () {
                    var e = this.modal
                    this.modal.setAttribute("aria-hidden", "true"), this.removeEventListeners(), this.scrollBehaviour("enable"), this.activeElement.focus(), this.config.onClose(this.modal), this.config.awaitCloseAnimation ? this.modal.addEventListener("animationend", function o() { e.classList.remove("is-open"), e.removeEventListener("animationend", o, !1) }, !1) : e.classList.remove("is-open")
                }
            }, {
                key: "scrollBehaviour", value: function (e) {
                    if (this.config.disableScroll) {
                        var o = document.querySelector("body")
                        switch (e) {
                            case "enable": Object.assign(o.style, { overflow: "initial", height: "initial" })
                                break
                            case "disable": Object.assign(o.style, { overflow: "hidden", height: "100vh" })
                        }
                    }
                }
            }, { key: "addEventListeners", value: function () { this.modal.addEventListener("touchstart", this.onClick), this.modal.addEventListener("click", this.onClick), document.addEventListener("keydown", this.onKeydown) } }, { key: "removeEventListeners", value: function () { this.modal.removeEventListener("touchstart", this.onClick), this.modal.removeEventListener("click", this.onClick), document.removeEventListener("keydown", this.onKeydown) } }, { key: "onClick", value: function (e) { e.target.hasAttribute(this.config.closeTrigger) && (this.closeModal(), e.preventDefault()) } }, { key: "onKeydown", value: function (e) { 27 === e.keyCode && this.closeModal(e), 9 === e.keyCode && this.maintainFocus(e) } }, {
                key: "getFocusableNodes", value: function () {
                    var e = this.modal.querySelectorAll(i)
                    return Object.keys(e).map(function (o) { return e[o] })
                }
            }, {
                key: "setFocusToFirstNode", value: function () {
                    if (!this.config.disableFocus) {
                        var e = this.getFocusableNodes()
                        e.length && e[0].focus()
                    }
                }
            }, {
                key: "maintainFocus", value: function (e) {
                    var o = this.getFocusableNodes()
                    if (this.modal.contains(document.activeElement)) {
                        var t = o.indexOf(document.activeElement)
                        e.shiftKey && 0 === t && (o[o.length - 1].focus(), e.preventDefault()), e.shiftKey || t !== o.length - 1 || (o[0].focus(), e.preventDefault())
                    } else o[0].focus()
                }
            }]), n
        }(), a = null, r = function (e, o) {
            var t = []
            return e.forEach(function (e) {
                var i = e.attributes[o].value
                void 0 === t[i] && (t[i] = []), t[i].push(e)
            }), t
        }, s = function (e) { if (!document.getElementById(e)) return console.warn("MicroModal v0.3.1: ❗Seems like you have missed %c'" + e + "'", "background-color: #f8f9fa;color: #50596c;font-weight: bold;", "ID somewhere in your code. Refer example below to resolve it."), console.warn("%cExample:", "background-color: #f8f9fa;color: #50596c;font-weight: bold;", '<div class="modal" id="' + e + '"></div>'), !1 }, l = function (e) { if (e.length <= 0) return console.warn("MicroModal v0.3.1: ❗Please specify at least one %c'micromodal-trigger'", "background-color: #f8f9fa;color: #50596c;font-weight: bold;", "data attribute."), console.warn("%cExample:", "background-color: #f8f9fa;color: #50596c;font-weight: bold;", '<a href="#" data-micromodal-trigger="my-modal"></a>'), !1 }, c = function (e, o) {
            if (l(e), !o) return !0
            for (var t in o) s(t)
            return !0
        }
        return {
            init: function (e) {
                var o = Object.assign({}, { openTrigger: "data-micromodal-trigger" }, e), i = [].concat(t(document.querySelectorAll("[" + o.openTrigger + "]"))), a = r(i, o.openTrigger)
                if (!0 !== o.debugMode || !1 !== c(i, a)) for (var s in a) {
                    var l = a[s]
                    o.targetModal = s, o.triggers = [].concat(t(l)), new n(o)
                }
            }, show: function (e, o) {
                var t = o || {}
                t.targetModal = e, !0 === t.debugMode && !1 === s(e) || (a = new n(t), a.showModal())
            }, close: function () { a.closeModal() }
        }
    }()
});
(function (root, factory)
{
    "use strict";
    root.SBModal = factory(window.SBBase);

}(this, function (sbBase)
{
    "use strict";

    var sbUtils = sbBase.Utils;
    var defaults = {

        id: "sb-modal-1",
        contentId: "sb-modal-1--content",

        // internationalization
        i18n: {
            title: "Popup",
            closeLabel: "Close"
        },

        onShow: null,
        onHide: null,

        template:
            '<div class="modal micromodal-slide" data-micromodal-trigger="<%this.id%>" id="<%this.id%>" aria-hidden="true" style="display:none">' +
                '<div class="modal__overlay" tabindex="-1" data-micromodal-close>' +
                    '<div class="modal__container" role="dialog" aria-modal="true" aria-labelledby="<%this.id%>-title">' +
                        '<header class="modal__header">' +
                            '<h2 class="modal__title custom-label-color" id="<%this.id%>-title">' +
                                "<%this.i18n.title%>" +
                            "</h2>" +
                            '<button class="modal__close sb-modal-close" data-micromodal-close aria-label="<%this.i18n.closeLabel%>"></button>' +
                        "</header>" +
                            '<main class="modal__content" id="<%this.contentId%>">' +
                        "</main>" +
                    "</div>" +
                "</div>" +
            "</div>"
},


    /**
     * SBModal constructor
     */
    SBModal = function(options)
    {
        var self = this,
            opts = self.config(options);

        var modalHtml = sbBase.TemplateEngine(opts.template, opts);
        var div = document.createElement("div");
        div.innerHTML = modalHtml.trim();
        document.body.appendChild(div.firstChild);
    };


    /**
     * public SBModal API
     */
    SBModal.prototype = {


        /**
         * configure functionality
         */
        config: function(options)
        {
            if (!this._o) {
                this._o = sbUtils.extend({}, defaults, true);
            }

            var opts = sbUtils.extend(this._o, options, true);

            return opts;
        },

        isVisible: function()
        {
            return this._v;
        },

        setContent: function (content) {
            var contentDiv = document.getElementById(this._o.contentId);
            contentDiv.innerHTML = "";
            if (content) {
                contentDiv.innerHTML = content;
            }
        },

        show: function () {
            var self = this;
            MicroModal.show(this._o.id,
                {
                    onClose: self.onClose()
                });

            if (this._o.onShow) {
                this._o.onShow();
            };
        },

        onClose: function()
        {
            if (this._o.onHide) {
                this._o.onHide();
            };
        },

        /**
         * GAME OVER
         */
        destroy: function()
        {
            this.hide();
        }

    };

    return SBModal;

}));
;
;(function (ctx) {

    function loadResource(url, type, title, callback) {
        var head = document.getElementsByTagName('head').item(0),
            res = null;
        type = (!type) ? '' : type;
        if (type.toLowerCase() == 'css') {
            res = document.createElement('link');
            res.type = 'text/css';
            res.href = url;
            res.rel = 'stylesheet';
            res.title = title;
        } else {
            res = document.createElement('script');
            res.src = url;
            res.type = 'text/javascript';
        }
        head.appendChild(res);

        // try to access the css rules
        var _canGetNodeRules = function (node) {
            var s = node.sheet || node.styleSheet;
            try {
                // try to load the css rules
                var r = s.cssRules;
                return true;
            } catch (e) {
                if (e.name === 'SecurityError') {
                    //console.log('security error when trying to access cssRules [Firefox?] -> considering it loaded');
                    return true;
                }
                return false;
            }

        };

        // watch the css loading
        var cssLoadWatcher = function (node) {
            // when the link element has finished processing it's data, we can access the stylesheet and rules
            if (_canGetNodeRules(node)) {
                if (callback) callback();
            } else {
                // not yet, let's wait
                window.setTimeout(function () {
                    cssLoadWatcher(node);
                }, 100);
            }
        };

        // start watching
        cssLoadWatcher(res);
    };
    
    var defaultsDynamicParams = {
        MultiProperty : false,
        HotelId : 7577,
        AutoLoad: true,
        CodLang : 'EN',
        DefaultLang: 'EN',
        Currency: 'EUR',
        Use12PersonLimit : false,
        OnlyMultiplies : false,
        MinStay : 1,
        ReleaseDays : 0,
        CheckInDays : [0,1,2,3,4,5,6],
        AvailableMealPlans : [4],//not used
        UseBookingInPage : false,//not used
        UseNewBooking : true,//not used
        UseResponsive : true,//not used
        UseGoogleAnalyticsIntegration : true,
        GoogleAnalyticsId : 'G-1TBK2C6J8P,UA-182924165-1',
        GAPageTrackerName : 'pageTracker',
        NumberOfMonths: 2,
        NumberOfMonthsVertical: 1,
        PortalId: null,
        Properties: null,
		UseIbe2: true,

        CustomQueryStringParams: [],
        GetCustomQueryStringParams: function() {
            var retVal = "";
            for (var i = 0, l = this.CustomQueryStringParams.length; i < l; i++) {
                if (!this.CustomQueryStringParams[i].name) { continue; }
                retVal += "&" + encodeURIComponent(this.CustomQueryStringParams[i].name);
                if (this.CustomQueryStringParams[i].value) {
                    retVal += "=" + encodeURIComponent(this.CustomQueryStringParams[i].value);
                }
            }
            return retVal;
        },

        Checkin: null,
        Checkout: null,
        
        TotRoomsHotel : 185,

        DefaultPersons: 2,

        PromoCode: '',
        
        MaxRooms : 4,
        MaxAdults : 10,
        MaxKids : 4,
        MinKidsAge : 0,
        MaxKidsAge : 10,
				
        OpenInNewWindow: true,
		
        AfterInitCallBack: null,

        HomesiteUrl : '',
        TabletAgents : ['ipad','android(?!.*mobile)'],
        MobileAgents : ['mobile', 'iphone', 'ipad', 'ipod', 'nokia', 'htc', 'samsung', 'symbian', 'blackberry', 'opera mobi', 'opera mini', 'windows ce', 'windows phone', 'android', 'palm', 'portable'],
        ExcludeMobileSiteForTablet : false,
        UseMobile : function() {
            var agent = navigator.userAgent.toLowerCase();
	
            if(this._checkAgent(agent, this.TabletAgents)) {
                return (this.ExcludeMobileSiteForTablet) ? false : true;
            }

            return (this._checkAgent(agent, this.MobileAgents)) ? true : false;
        },
        _checkAgent : function(agent, userAgentsArray) {
            for (var i = 0; i < userAgentsArray.length; i++) {
                var regex = new RegExp(userAgentsArray[i], 'i');
                if (regex.test(agent)) {
                    return true;
                }
            }
            return false;
        },
		
        Addresses : {
            HttpHost: 'https://www.simplebooking.it',
            CdnHost: 'https://cdn.simplebooking.it',
            ConvertoHost: 'https://converto.simplebooking.it'
        },

        Countries: [],
        Languages: [],

        Converto:
        {
            Labels: {
                PopoverTitle: {
                    AR:"نموذج طلب الامكانيات",
			AZ:"Boş otaqların yoxlanması",
			BG:"Формуляр за заявка за наличност",
			BR:"Formulário para solicitar a disponibilidade",
			CA:"Formulari de sol·licitud de disponibilitat",
			CS:"Ověření volné kapacity",
			DA:"Formular til anmodning om ledighed",
			DE:"Kontaktformular",
			EL:"Φόρμα αίτησης διαθεσιμότητας",
			EN:"Availability request form",
			ES:"Modulo de petición de disponibilidad",
			FR:"Formulaire de demande de disponibilité",
			HE:"טופס בדיקת זמינות",
			HR:"Upit o raspoloživim sobama",
			HU:"Árajánlatot kérek",
			ID:"Formulir permintaan ketersediaan",
			IT:"Modulo richiesta disponibilità",
			JA:"ご利用可能なリクエストフォーム",
			KO:"가능 여부 요청 양식",
			LT:"Užimtumo tikrinimo forma.",
			NL:"Formulier voor aanvraag beschikbaarheid",
			PL:"Formularz zapytania o dyspozycyjność",
			PT:"Formulário para solicitar a disponibilidade",
			RO:"Formulare cerere disponibilitate",
			RU:"Проверить наличие свободных номеров",
			SL:"Obrazec zahteve za razpoložljivost",
			TR:"Müsaitlik talep formu",
			UK:"Перевірити наявність вільних номерів",
			VI:"Phiếu yêu cầu cung cấp tình trạng phòng trống",
			ZH:"可用请求申请表"
                },
                Submit: {
                    DE:"Bestätigen",
			EN:"Confirm",
			ES:"Confirmar",
			FR:"Confirmer",
			HE:"אישור",
			IT:"Conferma",
			PT:"Confirma",
			RU:"Подтвердить",
			UK:"підтвердити"
                },
                CustomerName: {
                    DE:"Name",
			EN:"Name",
			ES:"Nombre",
			FR:"Prénom",
			HE:"שם",
			IT:"Nome",
			PT:"Nome",
			RU:"Имя",
			UK:"ім\'я"
                },
                CustomerLastName: {
                    DE:"Nachname",
			EN:"Last Name",
			ES:"Apellidos",
			FR:"Nom",
			HE:"שם משפחה",
			IT:"Cognome",
			PT:"Sobrenome",
			RU:"Фамилия",
			UK:"Прізвище"
                },
                CustomerEmail: {
                    DE:"E-Mail-Adresse",
			EN:"E-mail address",
			ES:"Email",
			FR:"Adresse mail",
			HE:"כתובת אימייל",
			IT:"Indirizzo e-mail",
			PT:"Endereço de email",
			RU:"E-mail адрес",
			UK:"E-mail адреса"
                },
                CustomerCountry: {
                    DE:"Land",
			EN:"Country",
			ES:"Pais",
			FR:"Pays",
			HE:"מדינה",
			IT:"Paese",
			PT:"País",
			RU:"Страна",
			UK:"Країна"
                },
                CustomerLanguage: {
                    DE:"Sprache",
			EN:"Language",
			ES:"Lengua",
			FR:"Langue",
			HE:"שפה",
			IT:"Lingua",
			PT:"Língua",
			RU:"Язык",
			UK:"Мова"
                },
                CustomerMobile: {
                    EN:"Mobile",
			ES:"Móvil",
			FR:"Portable",
			HE:"סלולרי",
			IT:"Cellulare",
			PT:"Telemóvel",
			RU:"Мобильный",
			UK:"мобільний"
                },
                CustomerTelephone: {
                    DE:"Telefon",
			EN:"Phone",
			ES:"Teléfono",
			FR:"Téléphone",
			HE:"טלפון",
			IT:"Telefono",
			PT:"Telefone",
			RU:"Телефон и факс",
			UK:"Телефон і факс"
                },
                Notes: {
                    DE:"Notizen",
			EN:"Notes",
			ES:"Anotaciones",
			FR:"Notes",
			HE:"הערות",
			IT:"Note",
			PT:"Notas",
			RU:"Примечания",
			UK:"Примітки"
                },
                AcceptPrivacy: {
                    AR:"اقر بانني قرات المعلومات المتعلقة بالتعامل مع بياناتي واوافق عليها (<a class=\"sb-privacy-popup-link\">Privacy Policy</a>)",
			AZ:"Şəxsi məlumatlarımın işlənməsi ilə bağlı məlumatları oxumuşam və razıyam. (<a class=\"sb-privacy-popup-link\"> Gizlilik Siyasəti </a>)",
			BG:"Прочетох информацията относно обработката на моите лични данни и се съгласявам. (<a class=\"sb-privacy-popup-link\"> Декларация за поверителност </a>)",
			BR:"Eu li as informações sobre o tratamento dos meus dados pessoais e concordo. (<a class=\"sb-privacy-popup-link\">Política de Privacidade</a>)",
			CA:"He llegit la informació relacionada amb el tractament de les meves dades personals i accepto. (<a class=\"sb-privacy-popup-link\" style=\"text-decoration:underline\">política de privacitat</a>)",
			CS:"Souhlasím se zpracováním mých osobních údajů. (<a class=\"sb-privacy-popup-link\">Ochrana soukromí</a>)",
			DA:"Jeg har læst oplysningerne vedrørende håndtering af mine personlige data, og jeg accepterer dette. (<a class=\"sb-privacy-popup-link\">Beskyttelse af personlige oplysninger</a>)",
			DE:"Ich stimme der Speicherung meiner persönlichen Daten zu. (<a class=\"sb-privacy-popup-link\">Datenschutz-Bestimmungen</a>)",
			EL:"Διάβασα την πληροφόρηση σχετικά με τον χειρισμό των προσωπικών μου δεδομένων και συμφωνώ. (<a class=\"sb-privacy-popup-link\">Privacy Policy</a>)",
			EN:"I have read the information regarding the handling of my personal data and I agree. (<a class=\"sb-privacy-popup-link\">Privacy Policy</a>)",
			ES:"He leído la información relacionada con el tratamiento de mis datos personales y acepto. (<a class=\"sb-privacy-popup-link\" style=\"text-decoration:underline\" style=\"text-decoration:underline\">Política De Privacidad</a>)",
			FR:"J\'ai lu les informations relatives au traitement de mes données personnelles et j\'accepte. (<a class=\"sb-privacy-popup-link\"  style=\"text-decoration:underline\">Politique de confidentialité </a>)",
			HE:"קראתי את המידע לגבי השימוש בנתונים האישיים שלי ואני מסכים לתנאים.  (<a class=\"sb-privacy-popup-link\">מדיניות פרטיות</a>)",
			HR:"Pročitao sam informacije vezane uz korištenje mojih osobnih podataka i slažem se. (<a class=\"sb-privacy-popup-link\"> privatnosti </a>)",
			HU:"Elolvastam a személyes adatok kezeléséről szóló szabályzatot és elfogadom. (<a class=\"sb-privacy-popup-link\">Privacy Policy</a>)",
			ID:"Saya telah membaca informasi terkait penanganan data pribadi saya dan saya setuju. (<a class=\"sb-privacy-popup-link\">Kebijakan Privasi</a>)",
			IT:"Acconsento al trattamento dei miei dati personali. (<a class=\"sb-privacy-popup-link\">Informativa sulla Privacy</a>)",
			JA:"個人情報扱いについての情報を読んで、同意します。(<a class=\"sb-privacy-popup-link\">Privacy Policy</a>)",
			KO:"본인은 개인 정보 취급에 관한 안내를 읽었으며 이에 동의합니다. (<a class=\"sb-privacy-popup-link\">개인 정보 정책</a>)",
			LT:"Aš perskaičiau informaciją susijusią su mano asmeninės informacijos apdorojimu ir sutinku su ja. (<a class=\"sb-privacy-popup-link\">Privatumo politika</a>)",
			NL:"Ik heb de informatie met betrekking tot de behandeling van mijn persoonsgegevens gelezen en ga ermee akkoord. (<a class=\"sb-privacy-popup-link\">Privacybeleid</a>)",
			PL:"Wyrażam zgodę na przetwarzanie danych osobowych. (<a class=\"sb-privacy-popup-link\">Polityka Prywatności</a>)",
			PT:"Eu li as informações sobre o tratamento dos meus dados pessoais e concordo. (<a class=\"sb-privacy-popup-link\">Política de Privacidade</a>)",
			RO:"Sunt de acord cu prelucrarea datelor mele personale. (<a class=\"sb-privacy-popup-link\">Politica De Confidențialitate</a>)",
			RU:"Даю свое согласие на обработку моих персональных данных. (<a class=\"sb-privacy-popup-link\">Политика Конфиденциальности</a>)",
			SL:"Prebral sem podatke v zvezi z ravnanjem z mojimi osebnimi podatki in se strinjam. (<a class=\"sb-privacy-popup-link\"> Pravilnik o zasebnosti </a>)",
			TR:"Kişisel bilgilerimin korunmasıyla ilgili bilgilendirmeyi okudum ve kabul ediyorum. (<a class=\"sb-privacy-popup-link\">Gizlilik Politikası</a>)",
			UK:"Даю свою згоду на обробку моїх персональних даних. (<a class=\"sb-privacy-popup-link\"> Політика Конфіденційності </a>)",
			VI:"Tôi đã đọc và hiểu các điều khoản liên quan tới việc cung cấp dữ liệu cá nhân và sau đây đồng ý. (<a class=\"sb-privacy-popup-link\">Privacy Policy</a>)",
			ZH:"我已阅读关于个人数据处理方式的信息并且表示同意。(<a class=\"sb-privacy-popup-link\">隐私政策</a>)"
                },
                AcceptNewsletter: {
                    AR:"ارغب الحصول على العروض من  Puerto Nuevo Baja Hotel & Villas",
			AZ:"Puerto Nuevo Baja Hotel & Villas üçün əlavə təkliflər qəbul etməyə razıyam",
			BG:"Бих искал да получавам оферти от Puerto Nuevo Baja Hotel & Villas",
			BR:"Desejo receber as ofertas de Puerto Nuevo Baja Hotel & Villas",
			CA:"M\'agradaria rebre ofertes de Puerto Nuevo Baja Hotel & Villas",
			CS:"Přeji si dostávat nabídky na Puerto Nuevo Baja Hotel & Villas",
			DA:"Jeg vil gerne modtage tilbud fra Puerto Nuevo Baja Hotel & Villas",
			DE:"Ich würde gerne Angebote von Puerto Nuevo Baja Hotel & Villas erhalten",
			EL:"Θα ήθελα να λαμβάνω προσφορές από Puerto Nuevo Baja Hotel & Villas",
			EN:"I would like to receive the newsletter and special offers from Puerto Nuevo Baja Hotel & Villas",
			ES:"Deseo recibir las ofertas de Puerto Nuevo Baja Hotel & Villas",
			FR:"Je souhaite recevoir les offres de Puerto Nuevo Baja Hotel & Villas",
			HE:"אני מאשר/ת קבלת דברי פרסום והודעות על מבצעים מPuerto Nuevo Baja Hotel & Villas",
			HR:"Želim primati ponude od Puerto Nuevo Baja Hotel & Villas",
			HU:"Hírlevelet kérek Puerto Nuevo Baja Hotel & Villas",
			ID:"Saya ingin menerima penawaran dari Puerto Nuevo Baja Hotel & Villas",
			IT:"Desidero ricevere le offerte di Puerto Nuevo Baja Hotel & Villas",
			JA:"Puerto Nuevo Baja Hotel & Villasからのオファーを受けたいです",
			KO:"Puerto Nuevo Baja Hotel & Villas로부터 이벤트를 수신받고 싶습니다.",
			LT:"Aš norėčiau gauti pasiūlymus iš Puerto Nuevo Baja Hotel & Villas",
			NL:"Ik wil aanbiedingen ontvangen van Puerto Nuevo Baja Hotel & Villas",
			PL:"Chciałbym otrzymywać oferty Puerto Nuevo Baja Hotel & Villas",
			PT:"Desejo receber as ofertas de Puerto Nuevo Baja Hotel & Villas",
			RO:"Doresc să primesc oferte de la Puerto Nuevo Baja Hotel & Villas",
			RU:"Я согласен получать дополнительные предложения по Puerto Nuevo Baja Hotel & Villas",
			SL:"Želim prejemati ponudbe od Puerto Nuevo Baja Hotel & Villas",
			TR:"Teklif formu almak istiyorum",
			UK:"Я згоден отримувати додаткові пропозиції по Puerto Nuevo Baja Hotel & Villas",
			VI:"Tôi muốn nhận các thông tin khuyến mại từ Puerto Nuevo Baja Hotel & Villas",
			ZH:"我想从Puerto Nuevo Baja Hotel & Villas接受优惠。"
                },
                RequiredMsg: {
                    DE:"Erforderlich",
			EN:"Required",
			ES:"Obligatorio",
			HE:"נדרש",
			IT:"Obbligatorio",
			RU:"Требуется",
			UK:"потрібно"
                },
                EmailMsg: {
                    DE:"Ungültig Emailadresse",
			EN:"Invalid e-mail address",
			ES:"Dirección de correo inválida",
			HE:"כתובת מייל לא חוקית",
			IT:"Indirizzo e-mail non valido",
			RU:"Неверный e-mail",
			UK:"Невірний e-mail"
                },
                RequiredFieldsLabel: {
                    EN:"required fields",
			IT:"campi obbligatori"
                }
            }
        },
        Localizations: {
            SundayFirst : {
                		EN : true,
		ES : false
            },
            FullMonth : {
                		EN : ['January','February','March','April','May','June','July','August','September','October','November','December'],
		ES : ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre']
            },
            SmallMonth : {
                		EN : ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
		ES : ['ene.','feb.','mar.','abr.','may.','jun.','jul.','ago.','sep.','oct.','nov.','dic.']
            },
            FullDay : {
                		EN : ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
		ES : ['domingo','lunes','martes','miércoles','jueves','viernes','sábado']
            },
            SmallDay : {
                		EN : ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'],
		ES : ['do.','lu.','ma.','mi.','ju.','vi.','sá.']
            },
            MealPlan : {
                		EN : ['Show any available','Breakfast Included','Half board','Full board','Room Only','All Inclusive'],
		ES : ['Muestra todos los disponibles','Alojamiento y Desayuno','Media Pensión','Pensión Completa','Solo alojamiento','Todo incluído']
            },

            Labels : {
                CheckinDate : { 
                    AR:"تاريخ الوصول: ",
			AZ:"Gəliş: ",
			BG:"Дата на пристигане: ",
			BR:"Data de chegada: ",
			CA:"Data d\'arribada: ",
			CS:"Datum příjezdu: ",
			DA:"Indtjekningsdato: ",
			DE:"Anreisedatum: ",
			EL:"Ημερομηνία άφιξης: ",
			EN:"Arrival Date: ",
			ES:"Fecha de llegada: ",
			FR:"Date d\'arrivée: ",
			HE:"תאריך הגעה: ",
			HR:"Datum dolaska: ",
			HU:"Érkezés dátuma: ",
			ID:"Tanggal Kedatangan: ",
			IT:"Data Arrivo: ",
			JA:"到着日: ",
			KO:"도착 날짜: ",
			LT:"Atvykimo data: ",
			NL:"Aankomstdatum: ",
			PL:"Data przyjazdu: ",
			PT:"Data de chegada: ",
			RO:"Data Sosirii: ",
			RU:"Дата заезда: ",
			SL:"Datum prihoda: ",
			TR:"Giriş Günü: ",
			UK:"дата заїзду: ",
			VI:"Ngày đến: ",
			ZH:"到达日期: " 
                },
                CheckoutDate : { 
                    AR:"تاريخ المغادرة: ",
			AZ:"Gediş: ",
			BG:"Дата на заминаване: ",
			BR:"Data de partida: ",
			CA:"Data de sortida: ",
			CS:"Datum odjezdu: ",
			DA:"Udtjekningsdato: ",
			DE:"Abreisedatum: ",
			EL:"Ημερομηνία αναχώρησης: ",
			EN:"Departure Date: ",
			ES:"Fecha de salida: ",
			FR:"Date de départ: ",
			HE:"תאריך עזיבה: ",
			HR:"Datum odlaska: ",
			HU:"Távozás dátuma: ",
			ID:"Tanggal Keberangkatan: ",
			IT:"Data Partenza: ",
			JA:"出発日: ",
			KO:"출발 날짜: ",
			LT:"Išvykimo data: ",
			NL:"Vertrekdatum: ",
			PL:"Data wyjazdu: ",
			PT:"Data de partida: ",
			RO:"Data Plecării: ",
			RU:"Дата выезда: ",
			SL:"Datum odhoda: ",
			TR:"Çıkış Günü: ",
			UK:"дата виїзду: ",
			VI:"Ngày đi: ",
			ZH:"离开日期: " 
                },
                NumNights : { 
                    AR:"الليالي: ",
			AZ:"Gecə: ",
			BG:"Нощувки: ",
			BR:"Noites: ",
			CA:"Nits: ",
			CS:"Nocí: ",
			DA:"Overnatninger: ",
			DE:"Nächte: ",
			EL:"Νύχτες: ",
			EN:"Nights: ",
			ES:"Noches: ",
			FR:"Nuits: ",
			HE:"לילות: ",
			HR:"Noći: ",
			HU:"Éjszaka száma: ",
			ID:"Malam: ",
			IT:"Notti: ",
			JA:"泊: ",
			KO:"박: ",
			NL:"Nachten: ",
			PL:"Noce: ",
			PT:"Noites: ",
			RO:"Nopţi: ",
			RU:"Hочей: ",
			SL:"Noči: ",
			TR:"Gece Sayısı: ",
			UK:"Hочей: ",
			VI:"Số đêm: ",
			ZH:"夜晚: " 
                },
                NumRooms : { 
                    AR:"الغرف: ",
			AZ:"Otaqlar: ",
			BG:"Стаи: ",
			BR:"Quartos: ",
			CA:"Habitacions: ",
			CS:"Pokoje: ",
			DA:"Værelser: ",
			DE:"Zimmer: ",
			EL:"Δωμάτια: ",
			EN:"Rooms: ",
			ES:"Habitaciones: ",
			FR:"Chambres: ",
			HE:"חדרים: ",
			HR:"Sobe: ",
			HU:"Szobák száma: ",
			ID:"Kamar: ",
			IT:"Camere: ",
			JA:"部屋: ",
			KO:"방: ",
			NL:"Kamers: ",
			PL:"Pokoje: ",
			PT:"Quartos: ",
			RO:"Camere: ",
			RU:"Номеров: ",
			SL:"Sobe: ",
			TR:"Oda: ",
			UK:"номерів: ",
			VI:"Số lượng phòng: ",
			ZH:"房间: " 
                },
                NumPersons : { 
                    AR:"الاشخاص: ",
			AZ:"Qonaq sayı: ",
			BG:"Хора: ",
			BR:"Pessoas: ",
			CA:"Persones: ",
			CS:"Osoby: ",
			DA:"Personer: ",
			DE:"Personen: ",
			EL:"Άτομα: ",
			EN:"Persons: ",
			ES:"Personas: ",
			FR:"Personnes: ",
			HE:"אורחים: ",
			HR:"Osobe: ",
			HU:"Vendégek száma: ",
			ID:"Orang: ",
			IT:"Persone: ",
			JA:"人: ",
			KO:"인원수: ",
			NL:"Personen: ",
			PL:"Osoby: ",
			PT:"Pessoas: ",
			RO:"Persoane: ",
			RU:"Гостей: ",
			SL:"Osebe: ",
			TR:"Kişi: ",
			UK:"гостей: ",
			VI:"Số người: ",
			ZH:"人数: " 
                },
                NumAdults : { 
                    AR:"كبار: ",
			AZ:"Böyüklər: ",
			BG:"Възрастни: ",
			BR:"Adultos: ",
			CA:"Adults: ",
			CS:"Dospělí: ",
			DA:"Voksne: ",
			DE:"Erw.: ",
			EL:"Ενήλικες: ",
			EN:"Adults: ",
			ES:"Adultos: ",
			FR:"Adultes: ",
			HE:"מבוגרים: ",
			HR:"Odrasli: ",
			HU:"Felnőttek: ",
			ID:"Dewasa: ",
			IT:"Adulti: ",
			JA:"大人: ",
			KO:"성인: ",
			NL:"Volwassenen: ",
			PL:"Dorośli: ",
			PT:"Adultos: ",
			RO:"Adulţi: ",
			RU:"Взрослых: ",
			SL:"Odrasli: ",
			TR:"Yetişkinler: ",
			UK:"дорослих: ",
			VI:"Số người lớn: ",
			ZH:"成人: " 
                },
                NumKids : { 
                    AR:"اطفال: ",
			AZ:"Uşaqlar: ",
			BG:"Деца: ",
			BR:"Crianças: ",
			CA:"Nens: ",
			CS:"Děti: ",
			DA:"Børn: ",
			DE:"Kinder: ",
			EL:"Παιδιά: ",
			EN:"Kids: ",
			ES:"Niños: ",
			FR:"Enfants: ",
			HE:"ילדים: ",
			HR:"Djeca: ",
			HU:"Gyerekek: ",
			ID:"Anak-anak: ",
			IT:"Bambini: ",
			JA:"子供: ",
			KO:"아동: ",
			NL:"Kinderen: ",
			PL:"Dzieci: ",
			PT:"Crianças: ",
			RO:"Copii: ",
			RU:"Детей: ",
			SL:"Otroci: ",
			TR:"Çocuklar: ",
			UK:"дітей: ",
			VI:"Số trẻ em: ",
			ZH:"孩子: " 
                },
                KidAge : { 
                    AR:"العمر: ",
			AZ:"Yaş: ",
			BG:"Възраст: ",
			BR:"Idade: ",
			CA:"Edat: ",
			CS:"Věk: ",
			DA:"Alder: ",
			DE:"Alter: ",
			EL:"Ηλικία: ",
			EN:"Age: ",
			ES:"Edad: ",
			FR:"Âge: ",
			HE:"גיל: ",
			HR:"Godina: ",
			HU:"Életkor: ",
			ID:"Usia: ",
			IT:"Età: ",
			JA:"年齢: ",
			KO:"나이: ",
			LT:"Amžius: ",
			NL:"Leeftijd: ",
			PL:"Wiek: ",
			PT:"Idade: ",
			RO:"Vârsta: ",
			RU:"Возраст: ",
			SL:"Starost: ",
			TR:"Yaş: ",
			UK:"вік: ",
			VI:"tuổi: ",
			ZH:"年龄: " 
                },
                RoomAllocation : { 
                    AR:"ضيوف غرفة رقم",
			AZ:"Otaqda qonaq sayı #",
			BG:"Гости за стая №",
			BR:"Hóspedes por quarto #",
			CA:"Hostes per a habitació #",
			CS:"Hostů v pokoji #",
			DA:"Gæster i værelse #",
			DE:"Gäste Zimmer #",
			EL:"Επισκέπτες για το δωμάτιο",
			EN:"Guests for room #",
			ES:"Huéspedes por habitación #",
			FR:"Hôtes chambre #",
			HE:"אורחים עבור חדר <span class=\"sb-room-index-pre\">#</span>",
			HR:"Gostiju po sobi",
			HU:"Vendégek száma szobánként",
			ID:"Tamu untuk kamar #",
			IT:"Ospiti camera #",
			JA:"＃番のお部屋",
			KO:"방 #       의 게스트",
			LT:"Svečių kambaryje #",
			NL:"Gasten voor kamer #",
			PL:"Liczba osób w pokoju #",
			PT:"Hóspedes por quarto #",
			RO:"Ocupanţi cameră #",
			RU:"Гостей в номере #",
			SL:"Gosti za sobo #",
			TR:"Oda için misafirler",
			UK:"Гостей в номері #",
			VI:"Khách/ phòng",
			ZH:"房客 #" 
                },
                MealPlan : { 
                    AR:"خطة الوجبات: ",
			AZ:"Qidalanma növü: ",
			BG:"План на хранене: ",
			BR:"Tipo de estadia: ",
			CA:"Règim de pensió: ",
			CS:"Stravování: ",
			DA:"Forplejning: ",
			DE:"Verpflegungsart: ",
			EL:"Πλάνο φαγητού: ",
			EN:"Meal plan: ",
			ES:"Régimen: ",
			FR:"Pension: ",
			HE:"סוג הארוחה: ",
			HR:"Plan prehrane: ",
			HU:"Étkezés: ",
			ID:"Paket makan: ",
			IT:"Trattamento: ",
			JA:"お食事プラン: ",
			KO:"식사: ",
			LT:"Maitinimo planas: ",
			NL:"Inbegrepen maaltijden: ",
			PL:"Wyżywienie: ",
			PT:"Tipo de estadia: ",
			RO:"Regim de masă: ",
			RU:"Тип питания: ",
			SL:"Načrt prehrane: ",
			TR:"Yemek Planı: ",
			UK:"Тип харчування: ",
			VI:"Gói ăn: ",
			ZH:"餐饮安排: " 
                },
                PromoCode : { 
                    AR:"رمز العرض: ",
			AZ:"Promo kodu: ",
			BG:"Промо код: ",
			BR:"Código promocional: ",
			CA:"Codi promocional: ",
			CS:"Promo kód: ",
			DA:"Kampagnekode: ",
			DE:"Promotioncode: ",
			EL:"Κωδικός προώθησης: ",
			EN:"Promo code: ",
			ES:"Código promocional: ",
			FR:"Code promotionnel: ",
			HE:"קוד קופון: ",
			HR:"Promo kod: ",
			HU:"Promóciós kód: ",
			ID:"Kode promo: ",
			IT:"Codice promo: ",
			JA:"プロモコード: ",
			KO:"프로모 코드: ",
			LT:"Nuolaidos kodas: ",
			NL:"Kortingscode: ",
			PL:"Kod promocyjny: ",
			PT:"Código promocional: ",
			RO:"Cod promo: ",
			RU:"Промокод: ",
			SL:"Promocijska koda: ",
			TR:"Promosyon Kodu: ",
			UK:"Промокод: ",
			VI:"Mã khyến mại: ",
			ZH:"促销代码: " 
                },
                CheckAvailability : { 
                    AR:"التاكد من الامكانية",
			AZ:"Axtar",
			BG:"Провери наличността",
			BR:"Verificar Disponibilidade",
			CA:"Comproveu disponibilitat",
			CS:"Ověření volné kapacity",
			DA:"Undersøg ledighed",
			DE:"Verfügbarkeit prüfen",
			EL:"Έλεγχος διαθεσιμότητας",
			EN:"Check Availability",
			ES:"Comprobar Disponibilidad",
			FR:"Vérifier la Disponibilité",
			HE:"בדקו זמינות",
			HR:"Provjeri raspoloživost",
			HU:"Szobák és árak megtekintése",
			ID:"Periksa Ketersediaan",
			IT:"Verifica Disponibilità",
			JA:"有効性を確認してください",
			KO:"가능 여부 확인",
			LT:"Patikrinkite užimtumą",
			NL:"Controleer beschikbaarheid",
			PL:"Sprawdź dyspozycyjność",
			PT:"Verificar Disponibilidade",
			RO:"Verificare Disponibilitate",
			RU:"Проверить наличие",
			SL:"Preveri razpoložljivost",
			TR:"Müsaitliği Kontrol Et",
			UK:"Перевірити наявність",
			VI:"Kiểm tra tình trạng phòng trống",
			ZH:"检查可用性" 
                },
                ModCancReservation : { 
                    AR:"تعديل / الغاء حجز متوفر",
			AZ:"Rezervasiyanı dəyişdir / ləğv edin",
			BG:"промяна / анулиране на съществуваща резервация",
			BR:"modificar/cancelar uma reserva existente",
			CA:"modifiqueu/cancel·leu una reserva existent",
			CS:"zrušit/změnit rezervaci",
			DA:"ændre/annullere en eksisterende reservation",
			DE:"Reservierung ändern/löschen",
			EL:"τροποποίηση/ακύρωση μιας υπάρχουσας κράτησης",
			EN:"modify/cancel an existing reservation",
			ES:"modificar / cancelar una reserva ya existente",
			FR:"modification/annulation de réservations",
			HE:"שינוי/ביטול הזמנה קיימת",
			HR:"promijeni/otkaži postojeću rezervaciju",
			HU:"Meglévő foglalás módosítása/törlése",
			ID:"modifikasi/batalkan reservasi yang ada",
			IT:"modifica/cancella una prenotazione",
			JA:"ただいまの予約の変更/キャンセル",
			KO:"기존 예약 변경/취소",
			LT:"keisti/atšaukti esamą rezervaciją",
			NL:"wijzig/annuleer een bestaande reservering",
			PL:"zmień/anuluj rezerwację",
			PT:"modificar / cancelar uma reserva existente",
			RO:"modifică/anulează o rezervare",
			RU:"Изменить/отменить бронь",
			SL:"spremeniti / preklicati obstoječo rezervacijo",
			TR:"Mevcut rezervasyonu düzenle/iptal et",
			UK:"Змінити / відмінити бронь",
			VI:"thay đổi/ hủy đặt phòng",
			ZH:"修改/取消已有预约" 
                },
                OpenSbPromoCode : {
                    AR:"وصول الشركات",
			AZ:"Korporativ giriş",
			BG:"Корпоративен достъп",
			BR:"Acesso corporativo",
			CA:"Accés empreses",
			CS:"Vstup pro partnery",
			DA:"Virksomhedsadgang",
			DE:"Corporate access",
			EL:"Εταιρική πρόσβαση",
			EN:"Corporate access",
			ES:"Acceso Empresas",
			FR:"Accès professionels",
			HE:"גישה תאגידית",
			HR:"Korporativni pristup",
			HU:"Vállalati hozzáférés",
			ID:"Akses perusahaan",
			IT:"Accesso convenzionato",
			JA:"法人利用",
			KO:"회사 접속 코드",
			LT:"Įmonių prieiga",
			NL:"Zakelijke toegang",
			PL:"Dostęp zarezerwowany",
			PT:"Corporate access",
			RO:"Acces firme",
			RU:"Корпоративный доступ",
			SL:"Korporativni dostop",
			TR:"Kurumsal erişim",
			UK:"Корпоративний доступ",
			VI:"Mã công ty",
			ZH:"访问企业" 
                },
                InfoSSL : {
                    AR:"جميع المعلومات محمية بتشفير SSL",
			AZ:"Bütün məlumatlar SSL sertifikatı ilə qorunur",
			BG:"Цялата информация, защитена със SSL силно криптиране",
			BR:"Todas as informações protegidas com criptografia SSL strong",
			CA:"Tota la informació està protegida per criptografia de seguretat SSL",
			CS:"Informace chráněné  certifikátem SSL 128 bit",
			DA:"Alle oplysninger er beskyttet med stærk SSL-kryptering",
			DE:"All information protected with SSL strong encryption",
			EL:"Όλες οι πληροφορίες προστατεύονται από ισχυρή αποδικοποίηση SSL",
			EN:"All information protected with SSL strong encryption",
			ES:"Toda la información está protegida mediante el cifrado de datos con tecnología SSL a 2048 bit",
			FR:"Toutes les informations protégées par un cryptage SSL fort",
			HE:"כל המידע מוגן עם הצפנת SSL חזקה",
			HR:"Sve informacije su zaštićene jakom SSL enkripcijom",
			HU:"Minden adat szigorúan védett és titkosított  SSL tanúsítvánnyal.",
			ID:"Semua informasi dilindungi dengan enkripsi kuat SSL",
			IT:"Informazioni protette con certificato SSL 128 bit",
			JA:"全ての情報はSSLの強力な暗号によって守られています",
			KO:"모든 정보는 SSL 의 암호화로 강력하게 보호됩니다.",
			LT:"Visa informacija yra apsaugota SSL stiprumo šifravimu",
			NL:"Alle gegevens worden beschermd via sterke SSL-encryptie",
			PL:"Informacje chronione certyfikatem SSL 128 bit",
			PT:"All information protected with SSL strong encryption",
			RO:"Informaţii protejate cu certificat SSL 128 bit",
			RU:"Вся информация защищена сертификатом SSL 128 bit",
			SL:"Vse informacije zaščitene s SSL močnim šifriranjem",
			TR:"Tüm bilgiler güçlü SSL kriptolama ile korunmaktadır",
			UK:"Вся інформація захищена сертифікатом SSL 128 bit",
			VI:"Tất cả thông tin được bảo vệ bằng mã hóa mạnh SSL",
			ZH:"所有信息经过SSL进行强加密保护。" 
                },
                TravelWithKids : {
                    AR:"السفر برفقة اطفال",
			AZ:"Uşaqlarla səyahət?",
			BG:"Пътуване с деца?",
			BR:"Viagem com crianças?",
			CA:"Viatgeu amb nens?",
			CS:"Cestujete s dětmi?",
			DA:"Rejser du med børn?",
			DE:"Travel with kids?",
			EL:"Ταξιδεύετε με παιδιά;",
			EN:"Travel with kids?",
			ES:"Viaja con niños?",
			FR:"Vous voyagez avec des enfants?",
			HE:"מטיילים עם ילדים?",
			HR:"Putujete s djecom?",
			HU:"Utazás gyerekekkel?",
			ID:"Perjalanan dengan anak-anak?",
			IT:"Viaggi con bambini?",
			JA:"お子様連れですか？",
			KO:"자녀와 함께 여행하세요?",
			LT:"Keliaujate su vaikais?",
			NL:"Reist u met kinderen?",
			PL:"Podróżujecie z dziećmi?",
			PT:"Travel with kids?",
			RO:"Călătoriţi cu copiii?",
			RU:"Путешествуете с детьми?",
			SL:"Potovati z otroki?",
			TR:"Çocukla mı seyehat ediyorsunuz?",
			UK:"Подорожуєте з дітьми?",
			VI:"Bạn có đi cùng trẻ em không?",
			ZH:"是否带孩子旅行？" 
                },
                SelectProperty : {
                    AR:"مبنى",
			AZ:"Otel:",
			BG:"Собственост",
			BR:"Propriedade:",
			CA:"Propietat:",
			CS:"Hotel:",
			DA:"Ejendom:",
			DE:"Betrieb:",
			EL:"Ξενοδοχείο:",
			EN:"Property:",
			ES:"Propiedad:",
			FR:"Propriété:",
			HE:"מלון:",
			HR:"Vlasništvo",
			HU:"Szállás:",
			ID:"Properti:",
			IT:"Struttura:",
			JA:"資産",
			KO:"호텔",
			LT:"Viešbutis:",
			NL:"Accommodatie:",
			PL:"Property:",
			PT:"Propriedade:",
			RO:"Property:",
			RU:"Гостиница:",
			SL:"Lastnost:",
			TR:"Otel:",
			UK:"Готель:",
			VI:"Khách sạn:",
			ZH:"属性：" 
                },
                Add: {
                    DE:"Hinzufügen",
			EN:"Add",
			ES:"Añade",
			FR:"Rajoutez",
			HE:"הוסף",
			IT:"Aggiungi",
			PT:"Adicionar",
			RU:"Добавить",
			UK:"Додати"
                },
                AddRoom: {
                    AR:"اضافة غرفة",
			AZ:"otaq əlavə edin",
			BG:"добави стая",
			BR:"Adicione um alojamento",
			CA:"afegiu habitació",
			CS:"Přidat pokoj",
			DA:"Tilføj et rum",
			DE:"Zimmer hinzufügen",
			EL:"Προσθήκη Δωματίου",
			EN:"add room",
			ES:"Añadir habitación",
			FR:"Ajoutez chambre",
			HE:"הוסיפו חדר",
			ID:"Tambah Kamar",
			IT:"aggiungi camera",
			JA:"客室の追加",
			KO:"객실 추가",
			LT:"priskirti kambarį",
			PT:"Adicione alojamento",
			RO:"Adaugaţi cameră",
			RU:"добавить номер",
			SL:"dodajte prostor",
			TR:"Oda ekle",
			UK:"додати номер",
			VI:"chọn loại phòng"
                },
                Confirm: {
                    AR:"تم",
			AZ:"ok, olundu",
			BG:"ОК, готово",
			BR:"Confirmar",
			CA:"D\'acord, fet",
			CS:"Potvrdit",
			DA:"Ok, færdig",
			DE:"bestätigen",
			EL:"Επιβεβάιωση",
			EN:"Ok, done",
			ES:"Confirmar",
			FR:"Confirmer",
			HE:"אישור",
			ID:"Konfirmasi",
			IT:"Ok, fatto",
			JA:"確定",
			KO:"확정",
			LT:"Gerai, baigta",
			PT:"Confirme",
			RO:"Confirmaţi",
			RU:"Ок, выполнено",
			SL:"Ok, končano",
			TR:"Onayla",
			UK:"Ок, виконано",
			VI:"Hoàn thành"
                },
                Cancel: {
                    AR:"الغاء",
			AZ:"Ləğv et",
			BG:"Отказ",
			BR:"Cancelar",
			CA:"Cancel·lar",
			CS:"Zrušit",
			DA:"Annuller",
			DE:"löschen",
			EL:"Ακύρωση",
			EN:"Cancel",
			ES:"Cancelar",
			FR:"Annuler",
			HE:"ביטול",
			ID:"Batalkan",
			IT:"Annulla",
			JA:"キャンセル",
			KO:"취소",
			LT:"Atšaukti",
			PT:"Cancelar",
			RO:"Anulare",
			RU:"Отмена",
			SL:"Prekliči",
			TR:"İptal",
			UK:"Скасувати",
			VI:"Hủy"
                },
                PromoInsert: {
                    AR:"ادخل رمز العرض",
			AZ:"Promo kodunu daxil edin",
			BG:"Въведете промокод",
			BR:"Código promocional",
			CA:"Introduir codi promocional",
			CS:"Promo kód",
			DA:"Indsæt kampagnekode",
			DE:"Promotioncode",
			EL:"Κωδικός προώθησης",
			EN:"Insert promo code",
			ES:"Código promocional",
			FR:"Code promotionnel",
			HE:"הקלידו קוד קופון",
			HR:"Promo kod",
			HU:"Promóciós kód",
			ID:"Kode promo",
			IT:"Inserisci codice promo",
			JA:"プロモコード",
			KO:"프로모 코드",
			LT:"Įveskite nuolaidos kodą",
			PL:"Kod promocyjny",
			PT:"Código promocional",
			RO:"Cod promo",
			RU:"Введите промокод",
			SL:"Vstavite promocijsko kodo",
			TR:"Promosyon Kodu",
			UK:"Введіть промокод",
			VI:"Nhập mã khuyến mại",
			ZH:"促销代码"
                },
                AllProperties: {
                    AR:"جميع العقارات",
			AZ:"Bütün otellər",
			BG:"Всички Хотели",
			BR:"Todas as propriedades",
			CA:"Tots els allotjaments",
			DE:"Alle Unterkünfte",
			EN:"All Properties",
			ES:"Todos los alojamientos",
			FR:"Toutes les propriétés",
			HE:"כל ההצעות",
			IT:"Tutte le Strutture",
			LT:"Visi viešbučiai",
			RU:"все отели",
			SL:"Vse lastnosti",
			TR:"Tüm oteller",
			UK:"всі готелі",
			VI:"Tất cả tài sản"
                },
                PropertyNotSelected: {
                    DE:"Wählen Sie eine Unterkunft",
			EN:"Select a property",
			ES:"Seleccionar una propiedad",
			FR:"Sélectionner une structure",
			HE:"בחר מלון",
			IT:"Selezionare una struttura",
			PT:"Selecione uma estrutura",
			RU:"Выбрать гостиницу",
			UK:"вибрати готель"
                }
            }
        }
    };
// Copy from jQuery.bindReady() function and modified (revisioned with jQuery 1.6.2)
if (ctx.ScriptBound) return;
var self = ctx;
ctx.init = function (){
    /*create style to hide box until css arrives and displays it*/
    res = document.createElement('style');
    res.type = 'text/css';
    res.innerHTML = 'div.sb {display: none}';
    var head = document.getElementsByTagName('head').item(0);
    head.appendChild(res);
    /* ---------- */
    //self.initScript();
    loadResource(defaultsDynamicParams.Addresses.CdnHost + '/search-box-style.axd', 'css', '', function () { self.initScript(); });
};
ctx.initAvailabilityFormScript = function () {
    if (ctx.availabilityFormInitialized)
        return;

    window.CreateAvailabilityForm = window.CreateAvailabilityForm || function (config) {
        return new AvailabilityForm(SBBase.Utils.extend(config, defaultsDynamicParams, false));
    };

    ctx.availabilityFormInitialized = true;

    if (!window.SBAvailabilityForm || !SBAvailabilityForm.q) {
        return;
    }

    for (var i = 0; i < SBAvailabilityForm.q.length; i++) {
        if (SBAvailabilityForm.q[i]) {
            var SBParameters = SBAvailabilityForm.q[i][0];
            SBBase.Utils.extend(SBParameters, defaultsDynamicParams, false);
            var availabilityForm = new AvailabilityForm(SBParameters);
            availabilityForm.init(false);
            if (SBParameters.Reference) {
                window[SBParameters.Reference] = {
                    enableSubmit: function () {
                        availabilityForm.enableSubmit();
                    }
                }
            };
        }
    }
};
ctx.initScript = function () {
    ctx.initAvailabilityFormScript();
    if (!window.SBSyncroBox) {
        return;
    }
    if (ctx.initialized || !SBSyncroBox.q)
        return;

    for (var i = 0; i < SBSyncroBox.q.length; i++){
        if (SBSyncroBox.q[i]) {			
            var SBParameters = SBSyncroBox.q[i][0];
            SBBase.Utils.extend(SBParameters, defaultsDynamicParams, false);
            window['searchBox_' + i] = searchBox = new SearchBox(SBParameters);
            if (SBParameters.Reference) {
                window[SBParameters.Reference] = {
                    showAvailabilityForm: function(options) {
                        searchBox.showAvailabilityForm(options);
                    }
                }
            };
            searchBox.init(false);
        }	
    }
    ctx.initialized = true;
    
    //utilityFunctionToOpenLink
    window.OpenSimpleBooking = window.OpenSimpleBooking ||
        function (lang, optionalHotelId) {
            window['searchBox_' + 0].openSB(lang, optionalHotelId);
        };
};
ctx.ScriptBound = true;
if (document.readyState === 'complete' || document.readyState === 'interactive'){
    self.init();
} else {
    if (document.addEventListener) {
        document.addEventListener("DOMContentLoaded", function () {
            document.removeEventListener("DOMContentLoaded", arguments.callee, false);
            self.init();
        }, false);
        window.addEventListener("DOMContentLoaded", function () {
            window.removeEventListener("DOMContentLoaded", arguments.callee, false);
            self.init();
        }, false);
    } else if (document.attachEvent) {
        document.attachEvent("onreadystatechange", function () {
            if (document.readyState === "complete") {
                document.detachEvent("onreadystatechange", arguments.callee);
                self.init();
            }
        });
        window.attachEvent('onload', function () {
            window.detachEvent('onload', arguments.callee);
            self.init();
        });
    }
}
})({});