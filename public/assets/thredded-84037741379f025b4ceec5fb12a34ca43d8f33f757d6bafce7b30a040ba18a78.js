/**
 * Copyright (c) 2016 hustcc
 * License: MIT
 * Version: v3.0.2
 * https://github.com/hustcc/timeago.js
**/
/* jshint expr: true */

!function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(root); // nodejs support
    module.exports['default'] = module.exports; // es6 support
  }
  else
    root.timeago = factory(root);
}(typeof window !== 'undefined' ? window : this,
function () {
  var indexMapEn = 'second_minute_hour_day_week_month_year'.split('_'),
    indexMapZh = '秒_分钟_小时_天_周_月_年'.split('_'),
    // build-in locales: en & zh_CN
    locales = {
      'en': function(number, index) {
        if (index === 0) return ['just now', 'right now'];
        var unit = indexMapEn[parseInt(index / 2)];
        if (number > 1) unit += 's';
        return [number + ' ' + unit + ' ago', 'in ' + number + ' ' + unit];
      },
      'zh_CN': function(number, index) {
        if (index === 0) return ['刚刚', '片刻后'];
        var unit = indexMapZh[parseInt(index / 2)];
        return [number + unit + '前', number + unit + '后'];
      }
    },
    // second, minute, hour, day, week, month, year(365 days)
    SEC_ARRAY = [60, 60, 24, 7, 365/7/12, 12],
    SEC_ARRAY_LEN = 6,
    // ATTR_DATETIME = 'datetime',
    ATTR_DATA_TID = 'data-tid',
    timers = {}; // real-time render timers

  // format Date / string / timestamp to Date instance.
  function toDate(input) {
    if (input instanceof Date) return input;
    if (!isNaN(input)) return new Date(toInt(input));
    if (/^\d+$/.test(input)) return new Date(toInt(input));
    input = (input || '').trim().replace(/\.\d+/, '') // remove milliseconds
      .replace(/-/, '/').replace(/-/, '/')
      .replace(/(\d)T(\d)/, '$1 $2').replace(/Z/, ' UTC') // 2017-2-5T3:57:52Z -> 2017-2-5 3:57:52UTC
      .replace(/([\+\-]\d\d)\:?(\d\d)/, ' $1$2'); // -04:00 -> -0400
    return new Date(input);
  }
  // change f into int, remove decimal. Just for code compression
  function toInt(f) {
    return parseInt(f);
  }
  // format the diff second to *** time ago, with setting locale
  function formatDiff(diff, locale, defaultLocale) {
    // if locale is not exist, use defaultLocale.
    // if defaultLocale is not exist, use build-in `en`.
    // be sure of no error when locale is not exist.
    locale = locales[locale] ? locale : (locales[defaultLocale] ? defaultLocale : 'en');
    // if (! locales[locale]) locale = defaultLocale;
    var i = 0,
      agoin = diff < 0 ? 1 : 0, // timein or timeago
      total_sec = diff = Math.abs(diff);

    for (; diff >= SEC_ARRAY[i] && i < SEC_ARRAY_LEN; i++) {
      diff /= SEC_ARRAY[i];
    }
    diff = toInt(diff);
    i *= 2;

    if (diff > (i === 0 ? 9 : 1)) i += 1;
    return locales[locale](diff, i, total_sec)[agoin].replace('%s', diff);
  }
  // calculate the diff second between date to be formated an now date.
  function diffSec(date, nowDate) {
    nowDate = nowDate ? toDate(nowDate) : new Date();
    return (nowDate - toDate(date)) / 1000;
  }
  /**
   * nextInterval: calculate the next interval time.
   * - diff: the diff sec between now and date to be formated.
   *
   * What's the meaning?
   * diff = 61 then return 59
   * diff = 3601 (an hour + 1 second), then return 3599
   * make the interval with high performace.
  **/
  function nextInterval(diff) {
    var rst = 1, i = 0, d = Math.abs(diff);
    for (; diff >= SEC_ARRAY[i] && i < SEC_ARRAY_LEN; i++) {
      diff /= SEC_ARRAY[i];
      rst *= SEC_ARRAY[i];
    }
    // return leftSec(d, rst);
    d = d % rst;
    d = d ? rst - d : rst;
    return Math.ceil(d);
  }
  // get the datetime attribute, `data-timeagp` / `datetime` are supported.
  function getDateAttr(node) {
    return getAttr(node, 'data-timeago') || getAttr(node, 'datetime');
  }
  // get the node attribute, native DOM and jquery supported.
  function getAttr(node, name) {
    if(node.getAttribute) return node.getAttribute(name); // native
    if(node.attr) return node.attr(name); // jquery
  }
  // set the node attribute, native DOM and jquery supported.
  function setTidAttr(node, val) {
    if(node.setAttribute) return node.setAttribute(ATTR_DATA_TID, val); // native
    if(node.attr) return node.attr(ATTR_DATA_TID, val); // jquery
  }
  // get the timer id of node.
  // remove the function, can save some bytes.
  // function getTidFromNode(node) {
  //   return getAttr(node, ATTR_DATA_TID);
  // }
  /**
   * timeago: the function to get `timeago` instance.
   * - nowDate: the relative date, default is new Date().
   * - defaultLocale: the default locale, default is en. if your set it, then the `locale` parameter of format is not needed of you.
   *
   * How to use it?
   * var timeagoLib = require('timeago.js');
   * var timeago = timeagoLib(); // all use default.
   * var timeago = timeagoLib('2016-09-10'); // the relative date is 2016-09-10, so the 2016-09-11 will be 1 day ago.
   * var timeago = timeagoLib(null, 'zh_CN'); // set default locale is `zh_CN`.
   * var timeago = timeagoLib('2016-09-10', 'zh_CN'); // the relative date is 2016-09-10, and locale is zh_CN, so the 2016-09-11 will be 1天前.
  **/
  function Timeago(nowDate, defaultLocale) {
    this.nowDate = nowDate;
    // if do not set the defaultLocale, set it with `en`
    this.defaultLocale = defaultLocale || 'en'; // use default build-in locale
    // for dev test
    // this.nextInterval = nextInterval;
  }
  // what the timer will do
  Timeago.prototype.doRender = function(node, date, locale) {
    var diff = diffSec(date, this.nowDate),
      self = this,
      tid;
    // delete previously assigned timeout's id to node
    node.innerHTML = formatDiff(diff, locale, this.defaultLocale);
    // waiting %s seconds, do the next render
    timers[tid = setTimeout(function() {
      self.doRender(node, date, locale);
      delete timers[tid];
    }, Math.min(nextInterval(diff) * 1000, 0x7FFFFFFF))] = 0; // there is no need to save node in object.
    // set attribute date-tid
    setTidAttr(node, tid);
  };
  /**
   * format: format the date to *** time ago, with setting or default locale
   * - date: the date / string / timestamp to be formated
   * - locale: the formated string's locale name, e.g. en / zh_CN
   *
   * How to use it?
   * var timeago = require('timeago.js')();
   * timeago.format(new Date(), 'pl'); // Date instance
   * timeago.format('2016-09-10', 'fr'); // formated date string
   * timeago.format(1473473400269); // timestamp with ms
  **/
  Timeago.prototype.format = function(date, locale) {
    return formatDiff(diffSec(date, this.nowDate), locale, this.defaultLocale);
  };
  /**
   * render: render the DOM real-time.
   * - nodes: which nodes will be rendered.
   * - locale: the locale name used to format date.
   *
   * How to use it?
   * var timeago = require('timeago.js')();
   * // 1. javascript selector
   * timeago.render(document.querySelectorAll('.need_to_be_rendered'));
   * // 2. use jQuery selector
   * timeago.render($('.need_to_be_rendered'), 'pl');
   *
   * Notice: please be sure the dom has attribute `datetime`.
  **/
  Timeago.prototype.render = function(nodes, locale) {
    if (nodes.length === undefined) nodes = [nodes];
    for (var i = 0, len = nodes.length; i < len; i++) {
      this.doRender(nodes[i], getDateAttr(nodes[i]), locale); // render item
    }
  };
  /**
   * setLocale: set the default locale name.
   *
   * How to use it?
   * var timeago = require('timeago.js')();
   * timeago.setLocale('fr');
  **/
  Timeago.prototype.setLocale = function(locale) {
    this.defaultLocale = locale;
  };
  /**
   * timeago: the function to get `timeago` instance.
   * - nowDate: the relative date, default is new Date().
   * - defaultLocale: the default locale, default is en. if your set it, then the `locale` parameter of format is not needed of you.
   *
   * How to use it?
   * var timeagoFactory = require('timeago.js');
   * var timeago = timeagoFactory(); // all use default.
   * var timeago = timeagoFactory('2016-09-10'); // the relative date is 2016-09-10, so the 2016-09-11 will be 1 day ago.
   * var timeago = timeagoFactory(null, 'zh_CN'); // set default locale is `zh_CN`.
   * var timeago = timeagoFactory('2016-09-10', 'zh_CN'); // the relative date is 2016-09-10, and locale is zh_CN, so the 2016-09-11 will be 1天前.
   **/
  function timeagoFactory(nowDate, defaultLocale) {
    return new Timeago(nowDate, defaultLocale);
  }
  /**
   * register: register a new language locale
   * - locale: locale name, e.g. en / zh_CN, notice the standard.
   * - localeFunc: the locale process function
   *
   * How to use it?
   * var timeagoFactory = require('timeago.js');
   *
   * timeagoFactory.register('the locale name', the_locale_func);
   * // or
   * timeagoFactory.register('pl', require('timeago.js/locales/pl'));
   **/
  timeagoFactory.register = function(locale, localeFunc) {
    locales[locale] = localeFunc;
  };

  /**
   * cancel: cancels one or all the timers which are doing real-time render.
   *
   * How to use it?
   * For canceling all the timers:
   * var timeagoFactory = require('timeago.js');
   * var timeago = timeagoFactory();
   * timeago.render(document.querySelectorAll('.need_to_be_rendered'));
   * timeagoFactory.cancel(); // will stop all the timers, stop render in real time.
   *
   * For canceling single timer on specific node:
   * var timeagoFactory = require('timeago.js');
   * var timeago = timeagoFactory();
   * var nodes = document.querySelectorAll('.need_to_be_rendered');
   * timeago.render(nodes);
   * timeagoFactory.cancel(nodes[0]); // will clear a timer attached to the first node, stop render in real time.
   **/
  timeagoFactory.cancel = function(node) {
    var tid;
    // assigning in if statement to save space
    if (node) {
      tid = getAttr(node, ATTR_DATA_TID); // get the timer of DOM node(native / jq).
      if (tid) {
        clearTimeout(tid);
        delete timers[tid];
      }
    } else {
      for (tid in timers) clearTimeout(tid);
      timers = {};
    }
  };

  return timeagoFactory;
});
/*
Unobtrusive JavaScript
https://github.com/rails/rails/blob/master/actionview/app/assets/javascripts
Released under the MIT license
 */


(function() {
  var context = this;

  (function() {
    (function() {
      this.Rails = {
        linkClickSelector: 'a[data-confirm], a[data-method], a[data-remote]:not([disabled]), a[data-disable-with], a[data-disable]',
        buttonClickSelector: {
          selector: 'button[data-remote]:not([form]), button[data-confirm]:not([form])',
          exclude: 'form button'
        },
        inputChangeSelector: 'select[data-remote], input[data-remote], textarea[data-remote]',
        formSubmitSelector: 'form',
        formInputClickSelector: 'form input[type=submit], form input[type=image], form button[type=submit], form button:not([type]), input[type=submit][form], input[type=image][form], button[type=submit][form], button[form]:not([type])',
        formDisableSelector: 'input[data-disable-with]:enabled, button[data-disable-with]:enabled, textarea[data-disable-with]:enabled, input[data-disable]:enabled, button[data-disable]:enabled, textarea[data-disable]:enabled',
        formEnableSelector: 'input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled, input[data-disable]:disabled, button[data-disable]:disabled, textarea[data-disable]:disabled',
        fileInputSelector: 'input[name][type=file]:not([disabled])',
        linkDisableSelector: 'a[data-disable-with], a[data-disable]',
        buttonDisableSelector: 'button[data-remote][data-disable-with], button[data-remote][data-disable]'
      };

    }).call(this);
  }).call(context);

  var Rails = context.Rails;

  (function() {
    (function() {
      var cspNonce;

      cspNonce = Rails.cspNonce = function() {
        var meta;
        meta = document.querySelector('meta[name=csp-nonce]');
        return meta && meta.content;
      };

    }).call(this);
    (function() {
      var expando, m;

      m = Element.prototype.matches || Element.prototype.matchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.msMatchesSelector || Element.prototype.oMatchesSelector || Element.prototype.webkitMatchesSelector;

      Rails.matches = function(element, selector) {
        if (selector.exclude != null) {
          return m.call(element, selector.selector) && !m.call(element, selector.exclude);
        } else {
          return m.call(element, selector);
        }
      };

      expando = '_ujsData';

      Rails.getData = function(element, key) {
        var ref;
        return (ref = element[expando]) != null ? ref[key] : void 0;
      };

      Rails.setData = function(element, key, value) {
        if (element[expando] == null) {
          element[expando] = {};
        }
        return element[expando][key] = value;
      };

      Rails.$ = function(selector) {
        return Array.prototype.slice.call(document.querySelectorAll(selector));
      };

    }).call(this);
    (function() {
      var $, csrfParam, csrfToken;

      $ = Rails.$;

      csrfToken = Rails.csrfToken = function() {
        var meta;
        meta = document.querySelector('meta[name=csrf-token]');
        return meta && meta.content;
      };

      csrfParam = Rails.csrfParam = function() {
        var meta;
        meta = document.querySelector('meta[name=csrf-param]');
        return meta && meta.content;
      };

      Rails.CSRFProtection = function(xhr) {
        var token;
        token = csrfToken();
        if (token != null) {
          return xhr.setRequestHeader('X-CSRF-Token', token);
        }
      };

      Rails.refreshCSRFTokens = function() {
        var param, token;
        token = csrfToken();
        param = csrfParam();
        if ((token != null) && (param != null)) {
          return $('form input[name="' + param + '"]').forEach(function(input) {
            return input.value = token;
          });
        }
      };

    }).call(this);
    (function() {
      var CustomEvent, fire, matches, preventDefault;

      matches = Rails.matches;

      CustomEvent = window.CustomEvent;

      if (typeof CustomEvent !== 'function') {
        CustomEvent = function(event, params) {
          var evt;
          evt = document.createEvent('CustomEvent');
          evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
          return evt;
        };
        CustomEvent.prototype = window.Event.prototype;
        preventDefault = CustomEvent.prototype.preventDefault;
        CustomEvent.prototype.preventDefault = function() {
          var result;
          result = preventDefault.call(this);
          if (this.cancelable && !this.defaultPrevented) {
            Object.defineProperty(this, 'defaultPrevented', {
              get: function() {
                return true;
              }
            });
          }
          return result;
        };
      }

      fire = Rails.fire = function(obj, name, data) {
        var event;
        event = new CustomEvent(name, {
          bubbles: true,
          cancelable: true,
          detail: data
        });
        obj.dispatchEvent(event);
        return !event.defaultPrevented;
      };

      Rails.stopEverything = function(e) {
        fire(e.target, 'ujs:everythingStopped');
        e.preventDefault();
        e.stopPropagation();
        return e.stopImmediatePropagation();
      };

      Rails.delegate = function(element, selector, eventType, handler) {
        return element.addEventListener(eventType, function(e) {
          var target;
          target = e.target;
          while (!(!(target instanceof Element) || matches(target, selector))) {
            target = target.parentNode;
          }
          if (target instanceof Element && handler.call(target, e) === false) {
            e.preventDefault();
            return e.stopPropagation();
          }
        });
      };

    }).call(this);
    (function() {
      var AcceptHeaders, CSRFProtection, createXHR, cspNonce, fire, prepareOptions, processResponse;

      cspNonce = Rails.cspNonce, CSRFProtection = Rails.CSRFProtection, fire = Rails.fire;

      AcceptHeaders = {
        '*': '*/*',
        text: 'text/plain',
        html: 'text/html',
        xml: 'application/xml, text/xml',
        json: 'application/json, text/javascript',
        script: 'text/javascript, application/javascript, application/ecmascript, application/x-ecmascript'
      };

      Rails.ajax = function(options) {
        var xhr;
        options = prepareOptions(options);
        xhr = createXHR(options, function() {
          var ref, response;
          response = processResponse((ref = xhr.response) != null ? ref : xhr.responseText, xhr.getResponseHeader('Content-Type'));
          if (Math.floor(xhr.status / 100) === 2) {
            if (typeof options.success === "function") {
              options.success(response, xhr.statusText, xhr);
            }
          } else {
            if (typeof options.error === "function") {
              options.error(response, xhr.statusText, xhr);
            }
          }
          return typeof options.complete === "function" ? options.complete(xhr, xhr.statusText) : void 0;
        });
        if ((options.beforeSend != null) && !options.beforeSend(xhr, options)) {
          return false;
        }
        if (xhr.readyState === XMLHttpRequest.OPENED) {
          return xhr.send(options.data);
        }
      };

      prepareOptions = function(options) {
        options.url = options.url || location.href;
        options.type = options.type.toUpperCase();
        if (options.type === 'GET' && options.data) {
          if (options.url.indexOf('?') < 0) {
            options.url += '?' + options.data;
          } else {
            options.url += '&' + options.data;
          }
        }
        if (AcceptHeaders[options.dataType] == null) {
          options.dataType = '*';
        }
        options.accept = AcceptHeaders[options.dataType];
        if (options.dataType !== '*') {
          options.accept += ', */*; q=0.01';
        }
        return options;
      };

      createXHR = function(options, done) {
        var xhr;
        xhr = new XMLHttpRequest();
        xhr.open(options.type, options.url, true);
        xhr.setRequestHeader('Accept', options.accept);
        if (typeof options.data === 'string') {
          xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        }
        if (!options.crossDomain) {
          xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        }
        CSRFProtection(xhr);
        xhr.withCredentials = !!options.withCredentials;
        xhr.onreadystatechange = function() {
          if (xhr.readyState === XMLHttpRequest.DONE) {
            return done(xhr);
          }
        };
        return xhr;
      };

      processResponse = function(response, type) {
        var parser, script;
        if (typeof response === 'string' && typeof type === 'string') {
          if (type.match(/\bjson\b/)) {
            try {
              response = JSON.parse(response);
            } catch (error) {}
          } else if (type.match(/\b(?:java|ecma)script\b/)) {
            script = document.createElement('script');
            script.setAttribute('nonce', cspNonce());
            script.text = response;
            document.head.appendChild(script).parentNode.removeChild(script);
          } else if (type.match(/\b(xml|html|svg)\b/)) {
            parser = new DOMParser();
            type = type.replace(/;.+/, '');
            try {
              response = parser.parseFromString(response, type);
            } catch (error) {}
          }
        }
        return response;
      };

      Rails.href = function(element) {
        return element.href;
      };

      Rails.isCrossDomain = function(url) {
        var e, originAnchor, urlAnchor;
        originAnchor = document.createElement('a');
        originAnchor.href = location.href;
        urlAnchor = document.createElement('a');
        try {
          urlAnchor.href = url;
          return !(((!urlAnchor.protocol || urlAnchor.protocol === ':') && !urlAnchor.host) || (originAnchor.protocol + '//' + originAnchor.host === urlAnchor.protocol + '//' + urlAnchor.host));
        } catch (error) {
          e = error;
          return true;
        }
      };

    }).call(this);
    (function() {
      var matches, toArray;

      matches = Rails.matches;

      toArray = function(e) {
        return Array.prototype.slice.call(e);
      };

      Rails.serializeElement = function(element, additionalParam) {
        var inputs, params;
        inputs = [element];
        if (matches(element, 'form')) {
          inputs = toArray(element.elements);
        }
        params = [];
        inputs.forEach(function(input) {
          if (!input.name || input.disabled) {
            return;
          }
          if (matches(input, 'select')) {
            return toArray(input.options).forEach(function(option) {
              if (option.selected) {
                return params.push({
                  name: input.name,
                  value: option.value
                });
              }
            });
          } else if (input.checked || ['radio', 'checkbox', 'submit'].indexOf(input.type) === -1) {
            return params.push({
              name: input.name,
              value: input.value
            });
          }
        });
        if (additionalParam) {
          params.push(additionalParam);
        }
        return params.map(function(param) {
          if (param.name != null) {
            return (encodeURIComponent(param.name)) + "=" + (encodeURIComponent(param.value));
          } else {
            return param;
          }
        }).join('&');
      };

      Rails.formElements = function(form, selector) {
        if (matches(form, 'form')) {
          return toArray(form.elements).filter(function(el) {
            return matches(el, selector);
          });
        } else {
          return toArray(form.querySelectorAll(selector));
        }
      };

    }).call(this);
    (function() {
      var allowAction, fire, stopEverything;

      fire = Rails.fire, stopEverything = Rails.stopEverything;

      Rails.handleConfirm = function(e) {
        if (!allowAction(this)) {
          return stopEverything(e);
        }
      };

      allowAction = function(element) {
        var answer, callback, message;
        message = element.getAttribute('data-confirm');
        if (!message) {
          return true;
        }
        answer = false;
        if (fire(element, 'confirm')) {
          try {
            answer = confirm(message);
          } catch (error) {}
          callback = fire(element, 'confirm:complete', [answer]);
        }
        return answer && callback;
      };

    }).call(this);
    (function() {
      var disableFormElement, disableFormElements, disableLinkElement, enableFormElement, enableFormElements, enableLinkElement, formElements, getData, matches, setData, stopEverything;

      matches = Rails.matches, getData = Rails.getData, setData = Rails.setData, stopEverything = Rails.stopEverything, formElements = Rails.formElements;

      Rails.handleDisabledElement = function(e) {
        var element;
        element = this;
        if (element.disabled) {
          return stopEverything(e);
        }
      };

      Rails.enableElement = function(e) {
        var element;
        element = e instanceof Event ? e.target : e;
        if (matches(element, Rails.linkDisableSelector)) {
          return enableLinkElement(element);
        } else if (matches(element, Rails.buttonDisableSelector) || matches(element, Rails.formEnableSelector)) {
          return enableFormElement(element);
        } else if (matches(element, Rails.formSubmitSelector)) {
          return enableFormElements(element);
        }
      };

      Rails.disableElement = function(e) {
        var element;
        element = e instanceof Event ? e.target : e;
        if (matches(element, Rails.linkDisableSelector)) {
          return disableLinkElement(element);
        } else if (matches(element, Rails.buttonDisableSelector) || matches(element, Rails.formDisableSelector)) {
          return disableFormElement(element);
        } else if (matches(element, Rails.formSubmitSelector)) {
          return disableFormElements(element);
        }
      };

      disableLinkElement = function(element) {
        var replacement;
        replacement = element.getAttribute('data-disable-with');
        if (replacement != null) {
          setData(element, 'ujs:enable-with', element.innerHTML);
          element.innerHTML = replacement;
        }
        element.addEventListener('click', stopEverything);
        return setData(element, 'ujs:disabled', true);
      };

      enableLinkElement = function(element) {
        var originalText;
        originalText = getData(element, 'ujs:enable-with');
        if (originalText != null) {
          element.innerHTML = originalText;
          setData(element, 'ujs:enable-with', null);
        }
        element.removeEventListener('click', stopEverything);
        return setData(element, 'ujs:disabled', null);
      };

      disableFormElements = function(form) {
        return formElements(form, Rails.formDisableSelector).forEach(disableFormElement);
      };

      disableFormElement = function(element) {
        var replacement;
        replacement = element.getAttribute('data-disable-with');
        if (replacement != null) {
          if (matches(element, 'button')) {
            setData(element, 'ujs:enable-with', element.innerHTML);
            element.innerHTML = replacement;
          } else {
            setData(element, 'ujs:enable-with', element.value);
            element.value = replacement;
          }
        }
        element.disabled = true;
        return setData(element, 'ujs:disabled', true);
      };

      enableFormElements = function(form) {
        return formElements(form, Rails.formEnableSelector).forEach(enableFormElement);
      };

      enableFormElement = function(element) {
        var originalText;
        originalText = getData(element, 'ujs:enable-with');
        if (originalText != null) {
          if (matches(element, 'button')) {
            element.innerHTML = originalText;
          } else {
            element.value = originalText;
          }
          setData(element, 'ujs:enable-with', null);
        }
        element.disabled = false;
        return setData(element, 'ujs:disabled', null);
      };

    }).call(this);
    (function() {
      var stopEverything;

      stopEverything = Rails.stopEverything;

      Rails.handleMethod = function(e) {
        var csrfParam, csrfToken, form, formContent, href, link, method;
        link = this;
        method = link.getAttribute('data-method');
        if (!method) {
          return;
        }
        href = Rails.href(link);
        csrfToken = Rails.csrfToken();
        csrfParam = Rails.csrfParam();
        form = document.createElement('form');
        formContent = "<input name='_method' value='" + method + "' type='hidden' />";
        if ((csrfParam != null) && (csrfToken != null) && !Rails.isCrossDomain(href)) {
          formContent += "<input name='" + csrfParam + "' value='" + csrfToken + "' type='hidden' />";
        }
        formContent += '<input type="submit" />';
        form.method = 'post';
        form.action = href;
        form.target = link.target;
        form.innerHTML = formContent;
        form.style.display = 'none';
        document.body.appendChild(form);
        form.querySelector('[type="submit"]').click();
        return stopEverything(e);
      };

    }).call(this);
    (function() {
      var ajax, fire, getData, isCrossDomain, isRemote, matches, serializeElement, setData, stopEverything,
        slice = [].slice;

      matches = Rails.matches, getData = Rails.getData, setData = Rails.setData, fire = Rails.fire, stopEverything = Rails.stopEverything, ajax = Rails.ajax, isCrossDomain = Rails.isCrossDomain, serializeElement = Rails.serializeElement;

      isRemote = function(element) {
        var value;
        value = element.getAttribute('data-remote');
        return (value != null) && value !== 'false';
      };

      Rails.handleRemote = function(e) {
        var button, data, dataType, element, method, url, withCredentials;
        element = this;
        if (!isRemote(element)) {
          return true;
        }
        if (!fire(element, 'ajax:before')) {
          fire(element, 'ajax:stopped');
          return false;
        }
        withCredentials = element.getAttribute('data-with-credentials');
        dataType = element.getAttribute('data-type') || 'script';
        if (matches(element, Rails.formSubmitSelector)) {
          button = getData(element, 'ujs:submit-button');
          method = getData(element, 'ujs:submit-button-formmethod') || element.method;
          url = getData(element, 'ujs:submit-button-formaction') || element.getAttribute('action') || location.href;
          if (method.toUpperCase() === 'GET') {
            url = url.replace(/\?.*$/, '');
          }
          if (element.enctype === 'multipart/form-data') {
            data = new FormData(element);
            if (button != null) {
              data.append(button.name, button.value);
            }
          } else {
            data = serializeElement(element, button);
          }
          setData(element, 'ujs:submit-button', null);
          setData(element, 'ujs:submit-button-formmethod', null);
          setData(element, 'ujs:submit-button-formaction', null);
        } else if (matches(element, Rails.buttonClickSelector) || matches(element, Rails.inputChangeSelector)) {
          method = element.getAttribute('data-method');
          url = element.getAttribute('data-url');
          data = serializeElement(element, element.getAttribute('data-params'));
        } else {
          method = element.getAttribute('data-method');
          url = Rails.href(element);
          data = element.getAttribute('data-params');
        }
        ajax({
          type: method || 'GET',
          url: url,
          data: data,
          dataType: dataType,
          beforeSend: function(xhr, options) {
            if (fire(element, 'ajax:beforeSend', [xhr, options])) {
              return fire(element, 'ajax:send', [xhr]);
            } else {
              fire(element, 'ajax:stopped');
              return false;
            }
          },
          success: function() {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return fire(element, 'ajax:success', args);
          },
          error: function() {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return fire(element, 'ajax:error', args);
          },
          complete: function() {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return fire(element, 'ajax:complete', args);
          },
          crossDomain: isCrossDomain(url),
          withCredentials: (withCredentials != null) && withCredentials !== 'false'
        });
        return stopEverything(e);
      };

      Rails.formSubmitButtonClick = function(e) {
        var button, form;
        button = this;
        form = button.form;
        if (!form) {
          return;
        }
        if (button.name) {
          setData(form, 'ujs:submit-button', {
            name: button.name,
            value: button.value
          });
        }
        setData(form, 'ujs:formnovalidate-button', button.formNoValidate);
        setData(form, 'ujs:submit-button-formaction', button.getAttribute('formaction'));
        return setData(form, 'ujs:submit-button-formmethod', button.getAttribute('formmethod'));
      };

      Rails.handleMetaClick = function(e) {
        var data, link, metaClick, method;
        link = this;
        method = (link.getAttribute('data-method') || 'GET').toUpperCase();
        data = link.getAttribute('data-params');
        metaClick = e.metaKey || e.ctrlKey;
        if (metaClick && method === 'GET' && !data) {
          return e.stopImmediatePropagation();
        }
      };

    }).call(this);
    (function() {
      var $, CSRFProtection, delegate, disableElement, enableElement, fire, formSubmitButtonClick, getData, handleConfirm, handleDisabledElement, handleMetaClick, handleMethod, handleRemote, refreshCSRFTokens;

      fire = Rails.fire, delegate = Rails.delegate, getData = Rails.getData, $ = Rails.$, refreshCSRFTokens = Rails.refreshCSRFTokens, CSRFProtection = Rails.CSRFProtection, enableElement = Rails.enableElement, disableElement = Rails.disableElement, handleDisabledElement = Rails.handleDisabledElement, handleConfirm = Rails.handleConfirm, handleRemote = Rails.handleRemote, formSubmitButtonClick = Rails.formSubmitButtonClick, handleMetaClick = Rails.handleMetaClick, handleMethod = Rails.handleMethod;

      if ((typeof jQuery !== "undefined" && jQuery !== null) && (jQuery.ajax != null) && !jQuery.rails) {
        jQuery.rails = Rails;
        jQuery.ajaxPrefilter(function(options, originalOptions, xhr) {
          if (!options.crossDomain) {
            return CSRFProtection(xhr);
          }
        });
      }

      Rails.start = function() {
        if (window._rails_loaded) {
          throw new Error('rails-ujs has already been loaded!');
        }
        window.addEventListener('pageshow', function() {
          $(Rails.formEnableSelector).forEach(function(el) {
            if (getData(el, 'ujs:disabled')) {
              return enableElement(el);
            }
          });
          return $(Rails.linkDisableSelector).forEach(function(el) {
            if (getData(el, 'ujs:disabled')) {
              return enableElement(el);
            }
          });
        });
        delegate(document, Rails.linkDisableSelector, 'ajax:complete', enableElement);
        delegate(document, Rails.linkDisableSelector, 'ajax:stopped', enableElement);
        delegate(document, Rails.buttonDisableSelector, 'ajax:complete', enableElement);
        delegate(document, Rails.buttonDisableSelector, 'ajax:stopped', enableElement);
        delegate(document, Rails.linkClickSelector, 'click', handleDisabledElement);
        delegate(document, Rails.linkClickSelector, 'click', handleConfirm);
        delegate(document, Rails.linkClickSelector, 'click', handleMetaClick);
        delegate(document, Rails.linkClickSelector, 'click', disableElement);
        delegate(document, Rails.linkClickSelector, 'click', handleRemote);
        delegate(document, Rails.linkClickSelector, 'click', handleMethod);
        delegate(document, Rails.buttonClickSelector, 'click', handleDisabledElement);
        delegate(document, Rails.buttonClickSelector, 'click', handleConfirm);
        delegate(document, Rails.buttonClickSelector, 'click', disableElement);
        delegate(document, Rails.buttonClickSelector, 'click', handleRemote);
        delegate(document, Rails.inputChangeSelector, 'change', handleDisabledElement);
        delegate(document, Rails.inputChangeSelector, 'change', handleConfirm);
        delegate(document, Rails.inputChangeSelector, 'change', handleRemote);
        delegate(document, Rails.formSubmitSelector, 'submit', handleDisabledElement);
        delegate(document, Rails.formSubmitSelector, 'submit', handleConfirm);
        delegate(document, Rails.formSubmitSelector, 'submit', handleRemote);
        delegate(document, Rails.formSubmitSelector, 'submit', function(e) {
          return setTimeout((function() {
            return disableElement(e);
          }), 13);
        });
        delegate(document, Rails.formSubmitSelector, 'ajax:send', disableElement);
        delegate(document, Rails.formSubmitSelector, 'ajax:complete', enableElement);
        delegate(document, Rails.formInputClickSelector, 'click', handleDisabledElement);
        delegate(document, Rails.formInputClickSelector, 'click', handleConfirm);
        delegate(document, Rails.formInputClickSelector, 'click', formSubmitButtonClick);
        document.addEventListener('DOMContentLoaded', refreshCSRFTokens);
        return window._rails_loaded = true;
      };

      if (window.Rails === Rails && fire(document, 'rails:attachBindings')) {
        Rails.start();
      }

    }).call(this);
  }).call(this);

  if (typeof module === "object" && module.exports) {
    module.exports = Rails;
  } else if (typeof define === "function" && define.amd) {
    define(Rails);
  }
}).call(this);
/** https://unpkg.com/autosize@4.0.2/dist/autosize.min.js **/

!function(e,t){if("function"==typeof define&&define.amd)define(["module","exports"],t);else if("undefined"!=typeof exports)t(module,exports);else{var n={exports:{}};t(n,n.exports),e.autosize=n.exports}}(this,function(e,t){"use strict";var n,o,p="function"==typeof Map?new Map:(n=[],o=[],{has:function(e){return-1<n.indexOf(e)},get:function(e){return o[n.indexOf(e)]},set:function(e,t){-1===n.indexOf(e)&&(n.push(e),o.push(t))},delete:function(e){var t=n.indexOf(e);-1<t&&(n.splice(t,1),o.splice(t,1))}}),c=function(e){return new Event(e,{bubbles:!0})};try{new Event("test")}catch(e){c=function(e){var t=document.createEvent("Event");return t.initEvent(e,!0,!1),t}}function r(r){if(r&&r.nodeName&&"TEXTAREA"===r.nodeName&&!p.has(r)){var e,n=null,o=null,i=null,d=function(){r.clientWidth!==o&&a()},l=function(t){window.removeEventListener("resize",d,!1),r.removeEventListener("input",a,!1),r.removeEventListener("keyup",a,!1),r.removeEventListener("autosize:destroy",l,!1),r.removeEventListener("autosize:update",a,!1),Object.keys(t).forEach(function(e){r.style[e]=t[e]}),p.delete(r)}.bind(r,{height:r.style.height,resize:r.style.resize,overflowY:r.style.overflowY,overflowX:r.style.overflowX,wordWrap:r.style.wordWrap});r.addEventListener("autosize:destroy",l,!1),"onpropertychange"in r&&"oninput"in r&&r.addEventListener("keyup",a,!1),window.addEventListener("resize",d,!1),r.addEventListener("input",a,!1),r.addEventListener("autosize:update",a,!1),r.style.overflowX="hidden",r.style.wordWrap="break-word",p.set(r,{destroy:l,update:a}),"vertical"===(e=window.getComputedStyle(r,null)).resize?r.style.resize="none":"both"===e.resize&&(r.style.resize="horizontal"),n="content-box"===e.boxSizing?-(parseFloat(e.paddingTop)+parseFloat(e.paddingBottom)):parseFloat(e.borderTopWidth)+parseFloat(e.borderBottomWidth),isNaN(n)&&(n=0),a()}function s(e){var t=r.style.width;r.style.width="0px",r.offsetWidth,r.style.width=t,r.style.overflowY=e}function u(){if(0!==r.scrollHeight){var e=function(e){for(var t=[];e&&e.parentNode&&e.parentNode instanceof Element;)e.parentNode.scrollTop&&t.push({node:e.parentNode,scrollTop:e.parentNode.scrollTop}),e=e.parentNode;return t}(r),t=document.documentElement&&document.documentElement.scrollTop;r.style.height="",r.style.height=r.scrollHeight+n+"px",o=r.clientWidth,e.forEach(function(e){e.node.scrollTop=e.scrollTop}),t&&(document.documentElement.scrollTop=t)}}function a(){u();var e=Math.round(parseFloat(r.style.height)),t=window.getComputedStyle(r,null),n="content-box"===t.boxSizing?Math.round(parseFloat(t.height)):r.offsetHeight;if(n<e?"hidden"===t.overflowY&&(s("scroll"),u(),n="content-box"===t.boxSizing?Math.round(parseFloat(window.getComputedStyle(r,null).height)):r.offsetHeight):"hidden"!==t.overflowY&&(s("hidden"),u(),n="content-box"===t.boxSizing?Math.round(parseFloat(window.getComputedStyle(r,null).height)):r.offsetHeight),i!==n){i=n;var o=c("autosize:resized");try{r.dispatchEvent(o)}catch(e){}}}}function i(e){var t=p.get(e);t&&t.destroy()}function d(e){var t=p.get(e);t&&t.update()}var l=null;"undefined"==typeof window||"function"!=typeof window.getComputedStyle?((l=function(e){return e}).destroy=function(e){return e},l.update=function(e){return e}):((l=function(e,t){return e&&Array.prototype.forEach.call(e.length?e:[e],function(e){return r(e)}),e}).destroy=function(e){return e&&Array.prototype.forEach.call(e.length?e:[e],i),e},l.update=function(e){return e&&Array.prototype.forEach.call(e.length?e:[e],d),e}),t.default=l,e.exports=t.default});
/** https://unpkg.com/textcomplete@0.17.1/dist/textcomplete.min.js **/

!function(e){function t(r){if(n[r])return n[r].exports;var i=n[r]={i:r,l:!1,exports:{}};return e[r].call(i.exports,i,i.exports,t),i.l=!0,i.exports}var n={};t.m=e,t.c=n,t.d=function(e,n,r){t.o(e,n)||Object.defineProperty(e,n,{configurable:!1,enumerable:!0,get:r})},t.n=function(e){var n=e&&e.__esModule?function(){return e.default}:function(){return e};return t.d(n,"a",n),n},t.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},t.p="",t(t.s=5)}([function(e,t,n){"use strict";function r(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0});var i=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),o=n(2),s=(function(e){e&&e.__esModule}(o),function(){function e(t,n,i){r(this,e),this.data=t,this.term=n,this.strategy=i}return i(e,[{key:"replace",value:function(e,t){var n=this.strategy.replace(this.data);if(null!==n){Array.isArray(n)&&(t=n[1]+t,n=n[0]);var r=this.strategy.matchText(e);if(r)return n=n.replace(/\$&/g,r[0]).replace(/\$(\d)/g,function(e,t){return r[parseInt(t,10)]}),[[e.slice(0,r.index),n,e.slice(r.index+r[0].length)].join(""),t]}}},{key:"render",value:function(){return this.strategy.template(this.data,this.term)}}]),e}());t.default=s},function(e){"use strict";function t(){}function n(e,t,n){this.fn=e,this.context=t,this.once=n||!1}function r(){this._events=new t,this._eventsCount=0}var i=Object.prototype.hasOwnProperty,o="~";Object.create&&(t.prototype=Object.create(null),(new t).__proto__||(o=!1)),r.prototype.eventNames=function(){var e,t,n=[];if(0===this._eventsCount)return n;for(t in e=this._events)i.call(e,t)&&n.push(o?t.slice(1):t);return Object.getOwnPropertySymbols?n.concat(Object.getOwnPropertySymbols(e)):n},r.prototype.listeners=function(e,t){var n=o?o+e:e,r=this._events[n];if(t)return!!r;if(!r)return[];if(r.fn)return[r.fn];for(var i=0,s=r.length,a=new Array(s);i<s;i++)a[i]=r[i].fn;return a},r.prototype.emit=function(e,t,n,r,i,s){var a=o?o+e:e;if(!this._events[a])return!1;var u,l,c=this._events[a],h=arguments.length;if(c.fn){switch(c.once&&this.removeListener(e,c.fn,void 0,!0),h){case 1:return c.fn.call(c.context),!0;case 2:return c.fn.call(c.context,t),!0;case 3:return c.fn.call(c.context,t,n),!0;case 4:return c.fn.call(c.context,t,n,r),!0;case 5:return c.fn.call(c.context,t,n,r,i),!0;case 6:return c.fn.call(c.context,t,n,r,i,s),!0}for(l=1,u=new Array(h-1);l<h;l++)u[l-1]=arguments[l];c.fn.apply(c.context,u)}else{var f,d=c.length;for(l=0;l<d;l++)switch(c[l].once&&this.removeListener(e,c[l].fn,void 0,!0),h){case 1:c[l].fn.call(c[l].context);break;case 2:c[l].fn.call(c[l].context,t);break;case 3:c[l].fn.call(c[l].context,t,n);break;case 4:c[l].fn.call(c[l].context,t,n,r);break;default:if(!u)for(f=1,u=new Array(h-1);f<h;f++)u[f-1]=arguments[f];c[l].fn.apply(c[l].context,u)}}return!0},r.prototype.on=function(e,t,r){var i=new n(t,r||this),s=o?o+e:e;return this._events[s]?this._events[s].fn?this._events[s]=[this._events[s],i]:this._events[s].push(i):(this._events[s]=i,this._eventsCount++),this},r.prototype.once=function(e,t,r){var i=new n(t,r||this,!0),s=o?o+e:e;return this._events[s]?this._events[s].fn?this._events[s]=[this._events[s],i]:this._events[s].push(i):(this._events[s]=i,this._eventsCount++),this},r.prototype.removeListener=function(e,n,r,i){var s=o?o+e:e;if(!this._events[s])return this;if(!n)return 0==--this._eventsCount?this._events=new t:delete this._events[s],this;var a=this._events[s];if(a.fn)a.fn!==n||i&&!a.once||r&&a.context!==r||(0==--this._eventsCount?this._events=new t:delete this._events[s]);else{for(var u=0,l=[],c=a.length;u<c;u++)(a[u].fn!==n||i&&!a[u].once||r&&a[u].context!==r)&&l.push(a[u]);l.length?this._events[s]=1===l.length?l[0]:l:0==--this._eventsCount?this._events=new t:delete this._events[s]}return this},r.prototype.removeAllListeners=function(e){var n;return e?(n=o?o+e:e,this._events[n]&&(0==--this._eventsCount?this._events=new t:delete this._events[n])):(this._events=new t,this._eventsCount=0),this},r.prototype.off=r.prototype.removeListener,r.prototype.addListener=r.prototype.on,r.prototype.setMaxListeners=function(){return this},r.prefixed=o,r.EventEmitter=r,e.exports=r},function(e,t){"use strict";function n(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function r(e){return e}Object.defineProperty(t,"__esModule",{value:!0});var i=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),o=function(){function e(t){n(this,e),this.props=t,this.cache=t.cache?{}:null}return i(e,[{key:"destroy",value:function(){return this.cache=null,this}},{key:"search",value:function(e,t,n){this.cache?this.searchWithCache(e,t,n):this.props.search(e,t,n)}},{key:"replace",value:function(e){return this.props.replace(e)}},{key:"searchWithCache",value:function(e,t,n){var r=this;this.cache&&this.cache[e]?t(this.cache[e]):this.props.search(e,function(n){r.cache&&(r.cache[e]=n),t(n)},n)}},{key:"matchText",value:function(e){return"function"==typeof this.match?this.match(e):e.match(this.match)}},{key:"match",get:function(){return this.props.match}},{key:"index",get:function(){return"number"==typeof this.props.index?this.props.index:2}},{key:"template",get:function(){return this.props.template||r}}]),e}();t.default=o},function(e,t){"use strict";function n(e){var t=e.getBoundingClientRect(),n=e.ownerDocument,r=n.defaultView,i=n.documentElement,o={top:t.top+r.pageYOffset,left:t.left+r.pageXOffset};return i&&(o.top-=i.clientTop,o.left-=i.clientLeft),o}function r(e){return e>=s&&e<=a}function i(e){var t=window.getComputedStyle(e);return r(t.lineHeight.charCodeAt(0))?r(t.lineHeight.charCodeAt(t.lineHeight.length-1))?parseFloat(t.lineHeight)*parseFloat(t.fontSize):parseFloat(t.lineHeight):o(e.nodeName,t)}function o(e,t){var n=document.body;if(!n)return 0;var r=document.createElement(e);r.innerHTML="&nbsp;",r.style.fontSize=t.fontSize,r.style.fontFamily=t.fontFamily,r.style.padding="0",n.appendChild(r),r instanceof HTMLTextAreaElement&&(r.rows=1);var i=r.offsetHeight;return n.removeChild(r),i}Object.defineProperty(t,"__esModule",{value:!0}),t.calculateElementOffset=n,t.getLineHeightPx=i,t.calculateLineHeightPx=o;var s=(t.createCustomEvent=function(){return"function"==typeof window.CustomEvent?function(e,t){return new document.defaultView.CustomEvent(e,{cancelable:t&&t.cancelable||!1,detail:t&&t.detail||void 0})}:function(e,t){var n=document.createEvent("CustomEvent");return n.initCustomEvent(e,!1,t&&t.cancelable||!1,t&&t.detail||void 0),n}}(),"0".charCodeAt(0)),a="9".charCodeAt(0)},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function i(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function o(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function s(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var a=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(1),l=r(u),c=n(3),h=n(0),f=(r(h),function(e){function t(){return i(this,t),o(this,(t.__proto__||Object.getPrototypeOf(t)).apply(this,arguments))}return s(t,e),a(t,[{key:"destroy",value:function(){return this}},{key:"applySearchResult",value:function(){throw new Error("Not implemented.")}},{key:"getCursorOffset",value:function(){throw new Error("Not implemented.")}},{key:"getBeforeCursor",value:function(){throw new Error("Not implemented.")}},{key:"emitMoveEvent",value:function(e){var t=(0,c.createCustomEvent)("move",{cancelable:!0,detail:{code:e}});return this.emit("move",t),t}},{key:"emitEnterEvent",value:function(){var e=(0,c.createCustomEvent)("enter",{cancelable:!0});return this.emit("enter",e),e}},{key:"emitChangeEvent",value:function(){var e=(0,c.createCustomEvent)("change",{detail:{beforeCursor:this.getBeforeCursor()}});return this.emit("change",e),e}},{key:"emitEscEvent",value:function(){var e=(0,c.createCustomEvent)("esc",{cancelable:!0});return this.emit("esc",e),e}},{key:"getCode",value:function(e){return 9===e.keyCode?"ENTER":13===e.keyCode?"ENTER":27===e.keyCode?"ESC":38===e.keyCode?"UP":40===e.keyCode?"DOWN":78===e.keyCode&&e.ctrlKey?"DOWN":80===e.keyCode&&e.ctrlKey?"UP":"OTHER"}}]),t}(l.default));t.default=f},function(e,t,n){"use strict";(function(e){function t(e){return e&&e.__esModule?e:{default:e}}var r=n(7),i=t(r),o=n(12),s=t(o),a=void 0;a=e.Textcomplete&&e.Textcomplete.editors?e.Textcomplete.editors:{},a.Textarea=s.default,e.Textcomplete=i.default,e.Textcomplete.editors=a}).call(t,n(6))},function(e){var t;t=function(){return this}();try{t=t||Function("return this")()||(0,eval)("this")}catch(e){"object"==typeof window&&(t=window)}e.exports=t},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function i(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function o(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function s(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var a=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(8),l=r(u),c=n(4),h=(r(c),n(10)),f=r(h),d=n(2),v=r(d),p=n(0),y=(r(p),n(1)),m=r(y),g=["handleChange","handleEnter","handleEsc","handleHit","handleMove","handleSelect"],b=function(e){function t(e){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{};i(this,t);var r=o(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));return r.completer=new l.default,r.isQueryInFlight=!1,r.nextPendingQuery=null,r.dropdown=new f.default(n.dropdown||{}),r.editor=e,r.options=n,g.forEach(function(e){r[e]=r[e].bind(r)}),r.startListening(),r}return s(t,e),a(t,[{key:"destroy",value:function(){var e=!(arguments.length>0&&void 0!==arguments[0])||arguments[0];return this.completer.destroy(),this.dropdown.destroy(),e&&this.editor.destroy(),this.stopListening(),this}},{key:"hide",value:function(){return this.dropdown.deactivate(),this}},{key:"register",value:function(e){var t=this;return e.forEach(function(e){t.completer.registerStrategy(new v.default(e))}),this}},{key:"trigger",value:function(e){return this.isQueryInFlight?this.nextPendingQuery=e:(this.isQueryInFlight=!0,this.nextPendingQuery=null,this.completer.run(e)),this}},{key:"handleHit",value:function(e){var t=e.searchResults;t.length?this.dropdown.render(t,this.editor.getCursorOffset()):this.dropdown.deactivate(),this.isQueryInFlight=!1,null!==this.nextPendingQuery&&this.trigger(this.nextPendingQuery)}},{key:"handleMove",value:function(e){"UP"===e.detail.code?this.dropdown.up(e):this.dropdown.down(e)}},{key:"handleEnter",value:function(e){var t=this.dropdown.getActiveItem();t?(this.dropdown.select(t),e.preventDefault()):this.dropdown.deactivate()}},{key:"handleEsc",value:function(e){this.dropdown.shown&&(this.dropdown.deactivate(),e.preventDefault())}},{key:"handleChange",value:function(e){null!=e.detail.beforeCursor?this.trigger(e.detail.beforeCursor):this.dropdown.deactivate()}},{key:"handleSelect",value:function(e){this.emit("select",e),e.defaultPrevented||this.editor.applySearchResult(e.detail.searchResult)}},{key:"startListening",value:function(){var e=this;this.editor.on("move",this.handleMove).on("enter",this.handleEnter).on("esc",this.handleEsc).on("change",this.handleChange),this.dropdown.on("select",this.handleSelect),["show","shown","render","rendered","selected","hidden","hide"].forEach(function(t){e.dropdown.on(t,function(){return e.emit(t)})}),this.completer.on("hit",this.handleHit)}},{key:"stopListening",value:function(){this.completer.removeAllListeners(),this.dropdown.removeAllListeners(),this.editor.removeListener("move",this.handleMove).removeListener("enter",this.handleEnter).removeListener("esc",this.handleEsc).removeListener("change",this.handleChange)}}]),t}(m.default);t.default=b},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function i(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function o(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function s(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var a=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(1),l=r(u),c=n(9),h=r(c),f=n(0),d=(r(f),n(2)),v=(r(d),["handleQueryResult"]),p=function(e){function t(){i(this,t);var e=o(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));return e.strategies=[],v.forEach(function(t){e[t]=e[t].bind(e)}),e}return s(t,e),a(t,[{key:"destroy",value:function(){return this.strategies.forEach(function(e){return e.destroy()}),this}},{key:"registerStrategy",value:function(e){return this.strategies.push(e),this}},{key:"run",value:function(e){var t=this.extractQuery(e);t?t.execute(this.handleQueryResult):this.handleQueryResult([])}},{key:"extractQuery",value:function(e){for(var t=0;t<this.strategies.length;t++){var n=h.default.build(this.strategies[t],e);if(n)return n}return null}},{key:"handleQueryResult",value:function(e){this.emit("hit",{searchResults:e})}}]),t}(l.default);t.default=p},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function i(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0});var o=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),s=n(0),a=r(s),u=n(2),l=(r(u),function(){function e(t,n,r){i(this,e),this.strategy=t,this.term=n,this.match=r}return o(e,null,[{key:"build",value:function(t,n){if("function"==typeof t.props.context){var r=t.props.context(n);if("string"==typeof r)n=r;else if(!r)return null}var i=t.matchText(n);return i?new e(t,i[t.index],i):null}}]),o(e,[{key:"execute",value:function(e){var t=this;this.strategy.search(this.term,function(n){e(n.map(function(e){return new a.default(e,t.term,t.strategy)}))},this.match)}}]),e}());t.default=l},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function i(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function o(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function s(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var a=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=n(1),l=r(u),c=n(11),h=r(c),f=n(0),d=(r(f),n(3)),v="dropdown-menu textcomplete-dropdown",p=function(e){function t(e){i(this,t);var n=o(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));n.shown=!1,n.items=[],n.activeItem=null,n.footer=e.footer,n.header=e.header,n.maxCount=e.maxCount||10,n.el.className=e.className||v,n.rotate=!e.hasOwnProperty("rotate")||e.rotate,n.placement=e.placement,n.itemOptions=e.item||{};var r=e.style;return r&&Object.keys(r).forEach(function(e){n.el.style[e]=r[e]}),n}return s(t,e),a(t,null,[{key:"createElement",value:function(){var e=document.createElement("ul"),t=e.style;t.display="none",t.position="absolute",t.zIndex="10000";var n=document.body;return n&&n.appendChild(e),e}}]),a(t,[{key:"destroy",value:function(){var e=this.el.parentNode;return e&&e.removeChild(this.el),this.clear()._el=null,this}},{key:"render",value:function(e,t){var n=this,r=(0,d.createCustomEvent)("render",{cancelable:!0});if(this.emit("render",r),r.defaultPrevented)return this;var i=e.map(function(e){return e.data}),o=e.slice(0,this.maxCount||e.length).map(function(e){return new h.default(e,n.itemOptions)});return this.clear().setStrategyId(e[0]).renderEdge(i,"header").append(o).renderEdge(i,"footer").show().setOffset(t),this.emit("rendered",(0,d.createCustomEvent)("rendered")),this}},{key:"deactivate",value:function(){return this.hide().clear()}},{key:"select",value:function(e){var t={searchResult:e.searchResult},n=(0,d.createCustomEvent)("select",{cancelable:!0,detail:t});return this.emit("select",n),n.defaultPrevented?this:(this.deactivate(),this.emit("selected",(0,d.createCustomEvent)("selected",{detail:t})),this)}},{key:"up",value:function(e){return this.shown?this.moveActiveItem("prev",e):this}},{key:"down",value:function(e){return this.shown?this.moveActiveItem("next",e):this}},{key:"getActiveItem",value:function(){return this.activeItem}},{key:"append",value:function(e){var t=this,n=document.createDocumentFragment();return e.forEach(function(e){t.items.push(e),e.appended(t),n.appendChild(e.el)}),this.el.appendChild(n),this}},{key:"setOffset",value:function(e){var t=document.documentElement;if(t){var n=this.el.offsetWidth;if(e.left){var r=t.clientWidth;e.left+n>r&&(e.left=r-n),this.el.style.left=e.left+"px"}else e.right&&(e.right-n<0&&(e.right=0),this.el.style.right=e.right+"px");this.isPlacementTop()?this.el.style.bottom=t.clientHeight-e.top+e.lineHeight+"px":this.el.style.top=e.top+"px"}return this}},{key:"show",value:function(){if(!this.shown){var e=(0,d.createCustomEvent)("show",{cancelable:!0});if(this.emit("show",e),e.defaultPrevented)return this;this.el.style.display="block",this.shown=!0,this.emit("shown",(0,d.createCustomEvent)("shown"))}return this}},{key:"hide",value:function(){if(this.shown){var e=(0,d.createCustomEvent)("hide",{cancelable:!0});if(this.emit("hide",e),e.defaultPrevented)return this;this.el.style.display="none",this.shown=!1,this.emit("hidden",(0,d.createCustomEvent)("hidden"))}return this}},{key:"clear",value:function(){return this.el.innerHTML="",this.items.forEach(function(e){return e.destroy()}),this.items=[],this}},{key:"moveActiveItem",value:function(e,t){var n="next"===e?this.activeItem?this.activeItem.next:this.items[0]:this.activeItem?this.activeItem.prev:this.items[this.items.length-1];return n&&(n.activate(),t.preventDefault()),this}},{key:"setStrategyId",value:function(e){var t=e&&e.strategy.props.id;return t?this.el.setAttribute("data-strategy",t):this.el.removeAttribute("data-strategy"),this}},{key:"renderEdge",value:function(e,t){var n=("header"===t?this.header:this.footer)||"",r="function"==typeof n?n(e):n,i=document.createElement("li");return i.classList.add("textcomplete-"+t),i.innerHTML=r,this.el.appendChild(i),this}},{key:"isPlacementTop",value:function(){return"top"===this.placement}},{key:"el",get:function(){return this._el||(this._el=t.createElement()),this._el}}]),t}(l.default);t.default=p},function(e,t,n){"use strict";function r(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}Object.defineProperty(t,"__esModule",{value:!0}),t.DEFAULT_CLASS_NAME=void 0;var i=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),o=n(0),s=(function(e){e&&e.__esModule}(o),t.DEFAULT_CLASS_NAME="textcomplete-item"),a=["onClick","onMouseover"],u=function(){function e(t,n){var i=this;r(this,e),this.searchResult=t,this.active=!1,this.className=n.className||s,this.activeClassName=this.className+" active",a.forEach(function(e){i[e]=i[e].bind(i)})}return i(e,[{key:"destroy",value:function(){this.el.removeEventListener("mousedown",this.onClick,!1),this.el.removeEventListener("mouseover",this.onMouseover,!1),this.el.removeEventListener("touchstart",this.onClick,!1),this.active&&(this.dropdown.activeItem=null),this._el=null}},{key:"appended",value:function(e){this.dropdown=e,this.siblings=e.items,this.index=this.siblings.length-1}},{key:"activate",value:function(){if(!this.active){var e=this.dropdown.getActiveItem();e&&e.deactivate(),this.dropdown.activeItem=this,this.active=!0,this.el.className=this.activeClassName}return this}},{key:"deactivate",value:function(){return this.active&&(this.active=!1,this.el.className=this.className,this.dropdown.activeItem=null),this}},{key:"onClick",value:function(e){e.preventDefault(),this.dropdown.select(this)}},{key:"onMouseover",value:function(){this.activate()}},{key:"el",get:function(){if(this._el)return this._el;var e=document.createElement("li");e.className=this.active?this.activeClassName:this.className;var t=document.createElement("a");return t.innerHTML=this.searchResult.render(),e.appendChild(t),this._el=e,e.addEventListener("mousedown",this.onClick),e.addEventListener("mouseover",this.onMouseover),e.addEventListener("touchstart",this.onClick),e}},{key:"next",get:function(){var e=void 0;if(this.index===this.siblings.length-1){if(!this.dropdown.rotate)return null;e=0}else e=this.index+1;return this.siblings[e]}},{key:"prev",get:function(){var e=void 0;if(0===this.index){if(!this.dropdown.rotate)return null;e=this.siblings.length-1}else e=this.index-1;return this.siblings[e]}}]),e}();t.default=u},function(e,t,n){"use strict";function r(e){return e&&e.__esModule?e:{default:e}}function i(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function o(e,t){if(!e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return!t||"object"!=typeof t&&"function"!=typeof t?e:t}function s(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function, not "+typeof t);e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}}),t&&(Object.setPrototypeOf?Object.setPrototypeOf(e,t):e.__proto__=t)}Object.defineProperty(t,"__esModule",{value:!0});var a=function(){function e(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}return function(t,n,r){return n&&e(t.prototype,n),r&&e(t,r),t}}(),u=function e(t,n,r){null===t&&(t=Function.prototype);var i=Object.getOwnPropertyDescriptor(t,n);if(void 0===i){var o=Object.getPrototypeOf(t);return null===o?void 0:e(o,n,r)}if("value"in i)return i.value;var s=i.get;if(void 0!==s)return s.call(r)},l=n(13),c=r(l),h=n(4),f=r(h),d=n(3),v=n(0),p=(r(v),n(14)),y=["onInput","onKeydown"],m=function(e){function t(e){i(this,t);var n=o(this,(t.__proto__||Object.getPrototypeOf(t)).call(this));return n.el=e,y.forEach(function(e){n[e]=n[e].bind(n)}),n.startListening(),n}return s(t,e),a(t,[{key:"destroy",value:function(){return u(t.prototype.__proto__||Object.getPrototypeOf(t.prototype),"destroy",this).call(this),this.stopListening(),this.el=null,this}},{key:"applySearchResult",value:function(e){var t=this.getBeforeCursor();if(null!=t){var n=e.replace(t,this.getAfterCursor());this.el.focus(),Array.isArray(n)&&((0,c.default)(this.el,n[0],n[1]),this.el.dispatchEvent(new Event("input")))}}},{key:"getCursorOffset",value:function(){var e=(0,d.calculateElementOffset)(this.el),t=this.getElScroll(),n=this.getCursorPosition(),r=(0,d.getLineHeightPx)(this.el),i=e.top-t.top+n.top+r,o=e.left-t.left+n.left;return"rtl"!==this.el.dir?{top:i,left:o,lineHeight:r}:{top:i,right:document.documentElement?document.documentElement.clientWidth-o:0,lineHeight:r}}},{key:"getBeforeCursor",value:function(){return this.el.selectionStart!==this.el.selectionEnd?null:this.el.value.substring(0,this.el.selectionEnd)}},{key:"getAfterCursor",value:function(){return this.el.value.substring(this.el.selectionEnd)}},{key:"getElScroll",value:function(){return{top:this.el.scrollTop,left:this.el.scrollLeft}}},{key:"getCursorPosition",value:function(){return p(this.el,this.el.selectionEnd)}},{key:"onInput",value:function(){this.emitChangeEvent()}},{key:"onKeydown",value:function(e){var t=this.getCode(e),n=void 0;"UP"===t||"DOWN"===t?n=this.emitMoveEvent(t):"ENTER"===t?n=this.emitEnterEvent():"ESC"===t&&(n=this.emitEscEvent()),n&&n.defaultPrevented&&e.preventDefault()}},{key:"startListening",value:function(){this.el.addEventListener("input",this.onInput),this.el.addEventListener("keydown",this.onKeydown)}},{key:"stopListening",value:function(){this.el.removeEventListener("input",this.onInput),this.el.removeEventListener("keydown",this.onKeydown)}}]),t}(f.default);t.default=m},function(e,t){"use strict";function n(){if("undefined"!=typeof Event)return new Event("input",{bubbles:!0,cancelable:!0});var e=document.createEvent("Event");return e.initEvent("input",!0,!0),e}Object.defineProperty(t,"__esModule",{value:!0}),t.default=function(e,t,r){for(var i=e.value,o=t+(r||""),s=document.activeElement,a=0,u=0;a<i.length&&a<o.length&&i[a]===o[a];)a++;for(;i.length-u-1>=0&&o.length-u-1>=0&&i[i.length-u-1]===o[o.length-u-1];)u++;a=Math.min(a,Math.min(i.length,o.length)-u),e.setSelectionRange(a,i.length-u);var l=o.substring(a,o.length-u);return e.focus(),document.execCommand("insertText",!1,l)||(e.value=o,e.dispatchEvent(n())),e.setSelectionRange(t.length,t.length),s&&s.focus(),e}},function(e){!function(){function t(e,t,o){if(!r)throw new Error("textarea-caret-position#getCaretCoordinates should only be called in a browser");var s=o&&o.debug||!1;if(s){var a=document.querySelector("#input-textarea-caret-position-mirror-div");a&&a.parentNode.removeChild(a)}var u=document.createElement("div");u.id="input-textarea-caret-position-mirror-div",document.body.appendChild(u);var l=u.style,c=window.getComputedStyle?getComputedStyle(e):e.currentStyle;l.whiteSpace="pre-wrap","INPUT"!==e.nodeName&&(l.wordWrap="break-word"),l.position="absolute",s||(l.visibility="hidden"),n.forEach(function(e){l[e]=c[e]}),i?e.scrollHeight>parseInt(c.height)&&(l.overflowY="scroll"):l.overflow="hidden",u.textContent=e.value.substring(0,t),"INPUT"===e.nodeName&&(u.textContent=u.textContent.replace(/\s/g," "));var h=document.createElement("span");h.textContent=e.value.substring(t)||".",u.appendChild(h);var f={top:h.offsetTop+parseInt(c.borderTopWidth),left:h.offsetLeft+parseInt(c.borderLeftWidth)};return s?h.style.backgroundColor="#aaa":document.body.removeChild(u),f}var n=["direction","boxSizing","width","height","overflowX","overflowY","borderTopWidth","borderRightWidth","borderBottomWidth","borderLeftWidth","borderStyle","paddingTop","paddingRight","paddingBottom","paddingLeft","fontStyle","fontVariant","fontWeight","fontStretch","fontSize","fontSizeAdjust","lineHeight","fontFamily","textAlign","textTransform","textIndent","textDecoration","letterSpacing","wordSpacing","tabSize","MozTabSize"],r="undefined"!=typeof window,i=r&&null!=window.mozInnerScreenX;void 0!==e&&void 0!==e.exports?e.exports=t:r&&(window.getCaretCoordinates=t)}()}]);





// We are not currently using any features that require the Babel polyfill
// Enable this if we do:
//- require babel/polyfill
;
"use strict";

window.Thredded = window.Thredded || {};
'use strict';

(function () {
  var isTurbolinks = 'Turbolinks' in window && window.Turbolinks.supported;
  var isTurbolinks5 = isTurbolinks && 'clearCache' in window.Turbolinks;

  var onPageLoadFiredOnce = false;
  var pageLoadCallbacks = [];
  var triggerOnPageLoad = function triggerOnPageLoad() {
    pageLoadCallbacks.forEach(function (callback) {
      callback();
    });
    onPageLoadFiredOnce = true;
  };

  // Fires the callback on DOMContentLoaded or a Turbolinks page load.
  // If called from an async script on the first page load, and the DOMContentLoad event
  // has already fired, will execute the callback immediately.
  window.Thredded.onPageLoad = function (callback) {
    pageLoadCallbacks.push(callback);
    // With async script loading, a callback may be added after the DOMContentLoaded event has already triggered.
    // This means we will receive neither a DOMContentLoaded event, nor a turbolinks:load event on Turbolinks 5.
    if (!onPageLoadFiredOnce && window.Thredded.DOMContentLoadedFired) {
      callback();
    }
  };

  if (isTurbolinks5) {
    // In Turbolinks 5.0.1, turbolinks:load may have already fired (before DOMContentLoaded).
    // If so, add our own DOMContentLoaded listener:
    // See: https://github.com/turbolinks/turbolinks/commit/69d353ea73d10ee6b25c2866fc5706879ba403e3
    if (window.Turbolinks.controller.lastRenderedLocation) {
      document.addEventListener('DOMContentLoaded', function () {
        triggerOnPageLoad();
      });
    }
    document.addEventListener('turbolinks:load', function () {
      triggerOnPageLoad();
    });
  } else {
    // Turbolinks Classic (with or without jQuery.Turbolinks), or no Turbolinks:
    if (!window.Thredded.DOMContentLoadedFired) {
      document.addEventListener('DOMContentLoaded', function () {
        triggerOnPageLoad();
      });
    }
    if (isTurbolinks) {
      document.addEventListener('page:load', function () {
        triggerOnPageLoad();
      });
    }
  }
})();
'use strict';

window.Thredded.onPageLoad(function () {
  if ('Rails' in window) {
    window.Rails.refreshCSRFTokens();
  } else if ('jQuery' in window && 'rails' in window.jQuery) {
    window.jQuery.rails.refreshCSRFTokens();
  }
});


/**
 * Return a function, that, as long as it continues to be invoked, will
 * not be triggered. The function will be called after it stops being
 * called for `wait` milliseconds. If `immediate` is passed, trigger the
 * function on the leading edge, instead of the trailing.
 * Based on https://john-dugan.com/javascript-debounce/.
 *
 * @param {Function} func
 * @param {Number} wait in milliseconds
 * @param {Boolean} immediate
 * @returns {Function}
 */


"use strict";

window.Thredded.debounce = function (func, wait, immediate) {
  var timeoutId = null;
  return function () {
    var context = this,
        args = arguments;
    var later = function later() {
      timeoutId = null;
      if (!immediate) {
        func.apply(context, args);
      }
    };
    var callNow = immediate && !timeoutId;
    clearTimeout(timeoutId);
    timeoutId = setTimeout(later, wait || 200);
    if (callNow) {
      func.apply(context, args);
    }
  };
};
'use strict';

window.Thredded.escapeHtml = function (text) {
  var node = document.createElement('div');
  node.textContent = text;
  return node.innerHTML;
};
"use strict";

window.Thredded.hideSoftKeyboard = function () {
  var activeElement = document.activeElement;
  if (!activeElement || !activeElement.blur) return;
  activeElement.blur();
};
'use strict';

window.Thredded.serializeForm = function (form) {
  // Can't use new FormData(form).entries() because it's not supported on any IE
  // The below is not a full replacement, but enough for Thredded's purposes.
  return Array.prototype.map.call(form.querySelectorAll('[name]'), function (e) {
    return encodeURIComponent(e.name) + '=' + encodeURIComponent(e.value);
  }).join('&');
};
'use strict';

(function () {
  var Thredded = window.Thredded;

  var COMPONENT_SELECTOR = '[data-thredded-currently-online]';
  var EXPANDED_CLASS = 'thredded--is-expanded';

  var handleMouseEnter = function handleMouseEnter(evt) {
    evt.target.classList.add(EXPANDED_CLASS);
  };

  var handleMouseLeave = function handleMouseLeave(evt) {
    evt.target.classList.remove(EXPANDED_CLASS);
  };

  var handleTouchStart = function handleTouchStart(evt) {
    evt.target.classList.toggle(EXPANDED_CLASS);
  };

  var initCurrentlyOnline = function initCurrentlyOnline(node) {
    node.addEventListener('mouseenter', handleMouseEnter);
    node.addEventListener('mouseleave', handleMouseLeave);
    node.addEventListener('touchstart', handleTouchStart);
  };

  Thredded.onPageLoad(function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (node) {
      initCurrentlyOnline(node);
    });
  });
})();
'use strict';

(function () {
  var COMPONENT_SELECTOR = '[data-thredded-flash-message]';

  document.addEventListener('turbolinks:before-cache', function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (node) {
      node.parentNode.removeChild(node);
    });
  });
})();
'use strict';

(function () {
  var Thredded = window.Thredded;

  Thredded.UserTextcomplete = {
    DROPDOWN_CLASS_NAME: 'thredded--textcomplete-dropdown',

    formatUser: function formatUser(_ref) {
      var avatar_url = _ref.avatar_url;
      var name = _ref.name;
      var display_name = _ref.display_name;

      return "<div class='thredded--textcomplete-user-result'>" + ('<img class=\'thredded--textcomplete-user-result__avatar\' src=\'' + Thredded.escapeHtml(avatar_url) + '\' >') + ('<span class=\'thredded--textcomplete-user-result__name\'>' + Thredded.escapeHtml(name) + '</span>') + (name !== display_name && display_name ? '<span class=\'thredded--textcomplete-user-result__display_name\'>' + Thredded.escapeHtml(display_name) + '</span>' : '') + '</div>';
    },

    searchFn: function searchFn(_ref2) {
      var url = _ref2.url;
      var autocompleteMinLength = _ref2.autocompleteMinLength;

      return function search(term, callback, match) {
        if (term.length < autocompleteMinLength) {
          callback([]);
          return;
        }
        var request = new XMLHttpRequest();
        request.open('GET', url + '?q=' + term, /* async */true);
        request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        request.onload = function () {
          // Ignore errors
          if (request.status < 200 || request.status >= 400) {
            callback([]);
            return;
          }
          callback(JSON.parse(request.responseText).results.map(function (_ref3) {
            var avatar_url = _ref3.avatar_url;
            var id = _ref3.id;
            var display_name = _ref3.display_name;
            var name = _ref3.name;

            return { avatar_url: avatar_url, id: id, name: name, display_name: display_name, match: match };
          }));
        };
        request.send();
      };
    }
  };

  document.addEventListener('turbolinks:before-cache', function () {
    Array.prototype.forEach.call(document.getElementsByClassName(Thredded.UserTextcomplete.DROPDOWN_CLASS_NAME), function (node) {
      node.parentNode.removeChild(node);
    });
  });
})();
'use strict';

var ThreddedMentionAutocompletion = {
  MATCH_RE: /(^@|\s@)"?([\w., \-()]+[\w.,\-()])$/,
  // the last letter has to not be a space so it doesn't match after replacement
  DROPDOWN_MAX_COUNT: 6,

  init: function init(form, textarea) {
    var editor = new Textcomplete.editors.Textarea(textarea);
    var textcomplete = new Textcomplete(editor, {
      dropdown: {
        className: Thredded.UserTextcomplete.DROPDOWN_CLASS_NAME,
        maxCount: ThreddedMentionAutocompletion.DROPDOWN_MAX_COUNT
      }
    });
    textcomplete.on('rendered', function () {
      if (textcomplete.dropdown.items.length) {
        textcomplete.dropdown.items[0].activate();
      }
    });
    textcomplete.register([{
      match: ThreddedMentionAutocompletion.MATCH_RE,
      search: Thredded.UserTextcomplete.searchFn({
        url: form.getAttribute('data-autocomplete-url'),
        autocompleteMinLength: parseInt(form.getAttribute('data-autocomplete-min-length'), 10)
      }),
      template: Thredded.UserTextcomplete.formatUser,
      replace: function replace(_ref) {
        var name = _ref.name;
        var match = _ref.match;

        var prefix = match[1];
        if (/[., ()]/.test(name)) {
          return prefix + '"' + name + '" ';
        } else {
          return '' + prefix + name + ' ';
        }
      }
    }]);
  }
};

window.ThreddedMentionAutocompletion = ThreddedMentionAutocompletion;
'use strict';

(function () {
  var Thredded = window.Thredded;
  var COMPONENT_SELECTOR = '.thredded--post--content--spoiler';
  var OPEN_CLASS = 'thredded--post--content--spoiler--is-open';

  Thredded.spoilers = {
    init: function init(root) {
      var _this = this;

      Array.prototype.forEach.call(root.querySelectorAll(COMPONENT_SELECTOR), function (node) {
        node.addEventListener('mousedown', function (evt) {
          evt.stopPropagation();
          _this.toggle(evt.currentTarget);
        });
        node.addEventListener('keypress', function (evt) {
          if (event.key === ' ' || event.key === 'Enter') {
            evt.preventDefault();
            evt.stopPropagation();
            _this.toggle(evt.currentTarget);
          }
        });
      });
    },

    toggle: function toggle(node) {
      var isOpen = node.classList.contains(OPEN_CLASS);
      node.classList.toggle(OPEN_CLASS);
      node.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
      node.firstElementChild.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
      node.lastElementChild.setAttribute('aria-hidden', isOpen ? 'true' : 'false');
    }
  };

  Thredded.onPageLoad(function () {
    Thredded.spoilers.init(document);
  });
})();
'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

(function () {
  var Thredded = window.Thredded;
  var PREVIEW_AREA_SELECTOR = '[data-thredded-preview-area]';
  var PREVIEW_AREA_POST_SELECTOR = '[data-thredded-preview-area-post]';

  var ThreddedPreviewArea = (function () {
    function ThreddedPreviewArea(form, textarea) {
      var _this = this;

      _classCallCheck(this, ThreddedPreviewArea);

      var preview = form.querySelector(PREVIEW_AREA_SELECTOR);
      if (!preview || !textarea) return;
      this.form = form;
      this.preview = preview;
      this.previewPost = form.querySelector(PREVIEW_AREA_POST_SELECTOR);
      this.previewUrl = this.preview.getAttribute('data-thredded-preview-url');

      var prevValue = null;
      var onChange = Thredded.debounce(function () {
        if (prevValue !== textarea.value) {
          _this.updatePreview();
          prevValue = textarea.value;
        }
      }, 200, false);

      textarea.addEventListener('input', onChange, false);

      this.requestId = 0;
    }

    _createClass(ThreddedPreviewArea, [{
      key: 'updatePreview',
      value: function updatePreview() {
        var _this2 = this;

        this.requestId++;
        var requestId = this.requestId;
        var request = new XMLHttpRequest();
        request.open(this.form.method, this.previewUrl, /* async */true);
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        request.onload = function () {
          if (
          // Ignore server errors
          request.status >= 200 && request.status < 400 &&
          // Ignore older responses received out-of-order
          requestId === _this2.requestId) {
            _this2.onPreviewResponse(request.responseText);
          }
        };
        request.send(Thredded.serializeForm(this.form));
      }
    }, {
      key: 'onPreviewResponse',
      value: function onPreviewResponse(data) {
        this.preview.style.display = 'block';
        this.previewPost.innerHTML = data;
        Thredded.spoilers.init(this.previewPost);
      }
    }]);

    return ThreddedPreviewArea;
  })();

  window.ThreddedPreviewArea = ThreddedPreviewArea;
})();
'use strict';

(function () {
  var Thredded = window.Thredded;
  var ThreddedMentionAutocompletion = window.ThreddedMentionAutocompletion;
  var ThreddedPreviewArea = window.ThreddedPreviewArea;
  var autosize = window.autosize;

  var COMPONENT_SELECTOR = '[data-thredded-post-form]';
  var CONTENT_TEXTAREA_SELECTOR = 'textarea[name$="[content]"]';

  var initPostForm = function initPostForm(form) {
    var textarea = form.querySelector(CONTENT_TEXTAREA_SELECTOR);
    autosize(textarea);
    new ThreddedPreviewArea(form, textarea);
    ThreddedMentionAutocompletion.init(form, textarea);
  };

  var destroyPostForm = function destroyPostForm(form) {
    autosize.destroy(form.querySelector(CONTENT_TEXTAREA_SELECTOR));
  };

  Thredded.onPageLoad(function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (node) {
      initPostForm(node);
    });
  });

  document.addEventListener('turbolinks:before-cache', function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (node) {
      destroyPostForm(node);
    });
  });
})();
'use strict';

(function () {
  var Thredded = window.Thredded;

  Thredded.onPageLoad(function () {
    Array.prototype.forEach.call(document.querySelectorAll('[data-thredded-quote-post]'), function (el) {
      el.addEventListener('click', onClick);
    });
  });

  function onClick(evt) {
    // Handle only left clicks with no modifier keys
    if (evt.button !== 0 || evt.ctrlKey || evt.altKey || evt.metaKey || evt.shiftKey) return;
    evt.preventDefault();
    var target = document.getElementById('post_content');
    target.scrollIntoView();
    target.value = '...';
    fetchReply(evt.target.getAttribute('data-thredded-quote-post'), function (replyText) {
      if (!target.ownerDocument.body.contains(target)) return;
      target.focus();
      target.value = replyText;

      var autosizeUpdateEvent = document.createEvent('Event');
      autosizeUpdateEvent.initEvent('autosize:update', true, false);
      target.dispatchEvent(autosizeUpdateEvent);
      // Scroll into view again as the size might have changed.
      target.scrollIntoView();
    }, function (errorMessage) {
      target.value = errorMessage;
    });
  }

  function fetchReply(url, onSuccess, onError) {
    var request = new XMLHttpRequest();
    request.open('GET', url, /* async */true);
    request.onload = function () {
      if (request.status >= 200 && request.status < 400) {
        onSuccess(request.responseText);
      } else {
        onError('Error (' + request.status + '): ' + request.statusText + ' ' + request.responseText);
      }
    };
    request.onerror = function () {
      onError('Network Error');
    };
    request.send();
  }
})();
'use strict';

(function () {
  var Thredded = window.Thredded;
  Thredded.isSubmitHotkey = function (evt) {
    // Ctrl+Enter.
    return evt.ctrlKey && (evt.keyCode === 13 || evt.keyCode === 10) /* http://crbug.com/79407 */;
  };

  document.addEventListener('keypress', function (evt) {
    if (Thredded.isSubmitHotkey(evt)) {
      var submitButton = document.querySelector('[data-thredded-submit-hotkey] [type="submit"]');
      if (!submitButton) return;
      evt.preventDefault();
      // Focus first for better visual feedback.
      submitButton.focus();
      submitButton.click();
    }
  });
})();
'use strict';

(function () {
  var COMPONENT_SELECTOR = '#thredded--container [data-time-ago]';
  var Thredded = window.Thredded;
  if ('timeago' in window) {
    (function () {
      var timeago = window.timeago;
      Thredded.onPageLoad(function () {
        var threddedContainer = document.querySelector('#thredded--container');
        if (!threddedContainer) return;
        timeago().render(document.querySelectorAll(COMPONENT_SELECTOR), threddedContainer.getAttribute('data-thredded-locale').replace('-', '_'));
      });
      document.addEventListener('turbolinks:before-cache', function () {
        timeago.cancel();
      });
    })();
  } else if ('jQuery' in window && 'timeago' in jQuery.fn) {
    (function () {
      var $ = window.jQuery;
      Thredded.onPageLoad(function () {
        var allowFutureWas = $.timeago.settings.allowFuture;
        $.timeago.settings.allowFuture = true;
        $(COMPONENT_SELECTOR).timeago();
        $.timeago.settings.allowFuture = allowFutureWas;
      });
    })();
  }
})();
'use strict';

(function () {
  var Thredded = window.Thredded;
  var ThreddedMentionAutocompletion = window.ThreddedMentionAutocompletion;
  var ThreddedPreviewArea = window.ThreddedPreviewArea;
  var autosize = window.autosize;

  var COMPONENT_SELECTOR = '[data-thredded-topic-form]';
  var TITLE_SELECTOR = '[name$="topic[title]"]';
  var CONTENT_TEXTAREA_SELECTOR = 'textarea[name$="[content]"]';
  var COMPACT_CLASS = 'thredded--is-compact';
  var EXPANDED_CLASS = 'thredded--is-expanded';
  var ESCAPE_KEY_CODE = 27;

  var initTopicForm = function initTopicForm(form) {
    var textarea = form.querySelector(CONTENT_TEXTAREA_SELECTOR);
    if (!textarea) {
      return;
    }
    autosize(textarea);
    new ThreddedPreviewArea(form, textarea);
    ThreddedMentionAutocompletion.init(form, textarea);

    if (!form.classList.contains(COMPACT_CLASS)) {
      return;
    }

    var title = form.querySelector(TITLE_SELECTOR);
    title.addEventListener('focus', function () {
      toggleExpanded(form, true);
    });

    [title, textarea].forEach(function (node) {
      // Un-expand on Escape key.
      node.addEventListener('keydown', function (evt) {
        if (evt.keyCode === ESCAPE_KEY_CODE) {
          evt.target.blur();
          toggleExpanded(form, false);
        }
      });

      // Un-expand on blur if the new focus element is outside of the same form and
      // all the form inputs are empty.
      node.addEventListener('blur', function () {
        // This listener will be fired right after the blur event has finished.
        var listener = function listener(evt) {
          if (!form.contains(evt.target) && !title.value && !textarea.value) {
            toggleExpanded(form, false);
          }
          document.body.removeEventListener('touchend', listener);
          document.body.removeEventListener('mouseup', listener);
        };
        document.body.addEventListener('mouseup', listener);
        document.body.addEventListener('touchend', listener);
      });
    });
  };

  var toggleExpanded = function toggleExpanded(form, expand) {
    if (expand) {
      form.classList.remove(COMPACT_CLASS);
      form.classList.add(EXPANDED_CLASS);
    } else {
      form.classList.remove(EXPANDED_CLASS);
      form.classList.add(COMPACT_CLASS);
    }
  };

  var destroyTopicForm = function destroyTopicForm(form) {
    var textarea = form.querySelector(CONTENT_TEXTAREA_SELECTOR);
    if (!textarea) {
      return;
    }
    autosize.destroy(textarea);
  };

  Thredded.onPageLoad(function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (node) {
      initTopicForm(node);
    });
  });

  document.addEventListener('turbolinks:before-cache', function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (node) {
      destroyTopicForm(node);
    });
  });
})();


// Makes topics in the list appear read as soon as the topic link is clicked,
// iff the topic link leads to the last page of the topic.
'use strict';

(function () {
  var Thredded = window.Thredded;

  var COMPONENT_SELECTOR = '[data-thredded-topics]';
  var TOPIC_UNREAD_CLASS = 'thredded--topic-unread';
  var TOPIC_READ_CLASS = 'thredded--topic-read';
  var POSTS_COUNT_SELECTOR = '.thredded--topics--posts-count';
  var POSTS_PER_PAGE = 50;

  function pageNumber(url) {
    var match = url.match(/\/page-(\d)$/);
    return match ? +match[1] : 1;
  }

  function totalPages(numPosts) {
    return Math.ceil(numPosts / POSTS_PER_PAGE);
  }

  function getTopicNode(node) {
    do {
      node = node.parentNode;
    } while (node && node.tagName !== 'ARTICLE');
    return node;
  }

  function initTopicsList(topicsList) {
    topicsList.addEventListener('click', function (evt) {
      var link = evt.target;
      if (link.tagName !== 'A' || link.parentNode.tagName !== 'H1') return;
      var topic = getTopicNode(link);
      if (pageNumber(link.href) === totalPages(+topic.querySelector(POSTS_COUNT_SELECTOR).textContent)) {
        topic.classList.add(TOPIC_READ_CLASS);
        topic.classList.remove(TOPIC_UNREAD_CLASS);
      }
    });
  }

  Thredded.onPageLoad(function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), initTopicsList);
  });
})();


// Submit GET forms with turbolinks
'use strict';

(function () {
  var Thredded = window.Thredded;
  var Turbolinks = window.Turbolinks;

  Thredded.onPageLoad(function () {
    if (!Turbolinks || !Turbolinks.supported) return;
    Array.prototype.forEach.call(document.querySelectorAll('[data-thredded-turboform]'), function (form) {
      form.addEventListener('submit', handleSubmit);
    });
  });

  var handleSubmit = function handleSubmit(evt) {
    evt.preventDefault();
    var form = evt.currentTarget;
    Turbolinks.visit(form.action + (form.action.indexOf('?') === -1 ? '?' : '&') + Thredded.serializeForm(form));

    // On mobile the soft keyboard doesn't won't go away after the submit since we're submitting with
    // Turbolinks. Hide it:
    Thredded.hideSoftKeyboard();
  };
})();


// Reflects the logic of user preference settings by enabling/disabling certain inputs.
'use strict';

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

(function () {
  var Thredded = window.Thredded;

  var COMPONENT_SELECTOR = '[data-thredded-user-preferences-form]';
  var BOUND_MESSAGEBOARD_NAME = 'data-thredded-bound-messageboard-pref';
  var UPDATE_ON_CHANGE_NAME = 'data-thredded-update-checkbox-on-change';

  var MessageboardPreferenceBinding = (function () {
    function MessageboardPreferenceBinding(form, genericCheckboxName, messageboardCheckboxName) {
      var _this = this;

      _classCallCheck(this, MessageboardPreferenceBinding);

      this.messageboardCheckbox = form.querySelector('[type="checkbox"][name="' + messageboardCheckboxName + '"]');
      if (!this.messageboardCheckbox) {
        return;
      }
      this.messageboardCheckbox.addEventListener('change', function () {
        _this.rememberMessageboardChecked();
      });
      this.rememberMessageboardChecked();

      this.genericCheckbox = form.querySelector('[type="checkbox"][name="' + genericCheckboxName + '"]');
      this.genericCheckbox.addEventListener('change', function () {
        _this.updateMessageboardCheckbox();
      });
      this.updateMessageboardCheckbox();
    }

    _createClass(MessageboardPreferenceBinding, [{
      key: 'rememberMessageboardChecked',
      value: function rememberMessageboardChecked() {
        this.messageboardCheckedWas = this.messageboardCheckbox.checked;
      }
    }, {
      key: 'updateMessageboardCheckbox',
      value: function updateMessageboardCheckbox() {
        var enabled = this.genericCheckbox.checked;
        this.messageboardCheckbox.disabled = !enabled;
        this.messageboardCheckbox.checked = enabled ? this.messageboardCheckedWas : false;
      }
    }]);

    return MessageboardPreferenceBinding;
  })();

  var UpdateOnChange = function UpdateOnChange(form, sourceElement, targetName) {
    _classCallCheck(this, UpdateOnChange);

    var target = form.querySelector('[type="checkbox"][name="' + targetName + '"]');
    if (!target) return;
    sourceElement.addEventListener('change', function () {
      target.checked = sourceElement.checked;
    });
  };

  var UserPreferencesForm = function UserPreferencesForm(form) {
    _classCallCheck(this, UserPreferencesForm);

    Array.prototype.forEach.call(form.querySelectorAll('input[' + BOUND_MESSAGEBOARD_NAME + ']'), function (element) {
      new MessageboardPreferenceBinding(form, element.name, element.getAttribute(BOUND_MESSAGEBOARD_NAME));
    });
    Array.prototype.forEach.call(form.querySelectorAll('input[' + UPDATE_ON_CHANGE_NAME + ']'), function (element) {
      new UpdateOnChange(form, element, element.getAttribute(UPDATE_ON_CHANGE_NAME));
    });
  };

  Thredded.onPageLoad(function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (form) {
      new UserPreferencesForm(form);
    });
  });
})();
'use strict';

(function () {
  var Thredded = window.Thredded;
  var autosize = window.autosize;

  var COMPONENT_SELECTOR = '[data-thredded-users-select]';

  Thredded.UsersSelect = {
    DROPDOWN_MAX_COUNT: 6
  };

  function parseNames(text) {
    var result = [];
    var current = [];
    var currentIndex = 0;
    var inQuoted = false;
    var inName = false;
    for (var i = 0; i < text.length; ++i) {
      var char = text.charAt(i);
      switch (char) {
        case '"':
          inQuoted = !inQuoted;
          break;
        case ' ':
          if (inName) current.push(char);
          break;
        case ',':
          if (inQuoted) {
            current.push(char);
          } else {
            inName = false;
            if (current.length) {
              result.push({ name: current.join(''), index: currentIndex });
              current.length = 0;
            }
          }
          break;
        default:
          if (!inName) currentIndex = i;
          inName = true;
          current.push(char);
      }
    }
    if (current.length) result.push({ name: current.join(''), index: currentIndex });
    return result;
  }

  var initUsersSelect = function initUsersSelect(textarea) {
    autosize(textarea);
    // Prevent multiple lines
    textarea.addEventListener('keypress', function (evt) {
      if (evt.keyCode === 13 || evt.keyCode === 10) {
        evt.preventDefault();
      }
    });
    var editor = new Textcomplete.editors.Textarea(textarea);
    var textcomplete = new Textcomplete(editor, {
      dropdown: {
        className: Thredded.UserTextcomplete.DROPDOWN_CLASS_NAME,
        maxCount: Thredded.UsersSelect.DROPDOWN_MAX_COUNT
      }
    });

    var searchFn = Thredded.UserTextcomplete.searchFn({
      url: textarea.getAttribute('data-autocomplete-url'),
      autocompleteMinLength: parseInt(textarea.getAttribute('data-autocomplete-min-length'), 10)
    });
    textcomplete.on('rendered', function () {
      if (textcomplete.dropdown.items.length) {
        textcomplete.dropdown.items[0].activate();
      }
    });
    textcomplete.register([{
      index: 0,
      match: function match(text) {
        var names = parseNames(text);
        if (names.length) {
          var _names = names[names.length - 1];
          var _name = _names.name;
          var index = _names.index;

          var matchData = [_name];
          matchData.index = index;
          return matchData;
        } else {
          return null;
        }
      },
      search: function search(term, callback, match) {
        searchFn(term, function (results) {
          var names = parseNames(textarea.value).map(function (_ref) {
            var name = _ref.name;
            return name;
          });
          callback(results.filter(function (result) {
            return names.indexOf(result.name) === -1;
          }));
        }, match);
      },
      template: Thredded.UserTextcomplete.formatUser,
      replace: function replace(_ref2) {
        var name = _ref2.name;

        if (/,/.test(name)) {
          return '"' + name + '", ';
        } else {
          return name + ', ';
        }
      }
    }]);
  };

  function destroyUsersSelect(textarea) {
    autosize.destroy(textarea);
  }

  window.Thredded.onPageLoad(function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (node) {
      initUsersSelect(node);
    });
  });

  document.addEventListener('turbolinks:before-cache', function () {
    Array.prototype.forEach.call(document.querySelectorAll(COMPONENT_SELECTOR), function (node) {
      destroyUsersSelect(node);
    });
  });
})();
"use strict";
"use strict";
