var DEBUG = true;

// #region Common Types

var TDEF = false;

var TInt: Int;
var TFloat: Float;
var TBool: Bool;
var TString: String;
var TDynamic: Dynamic;
var TAny: Any;

var TPlayer: Player;

var TZone: Zone;

var TUnitKind: UnitKind;
var TUnit = TDEF? (
	me().getWarchief()
) :null;

var TBuildingKind: BuildingKind;
var TBuilding = TDEF? (
	TZone.buildings.copy()[0]
) :null;

var TUiSfxKind: UiSfxKind;

var TResourceKind: ResourceKind;

// #endregion

// #region Utils

function log(value: Dynamic) {
	if (DEBUG) {
		debug(value + '');
	}
}
function logColor(value: Dynamic, color: Int) {
	if (DEBUG) {
		debug(value + '', color);
	}
}

function txtBr(value: Dynamic) {
	return '[' + value + ']';
}

function arrayFindIndex(array: Dynamic, callback): Int {
	if(TDEF) callback = function type(item: Dynamic, index: Int, array: Array<Dynamic>): Bool {};

	var arr: Array<Dynamic> = array;

	var index = 0;
	while (index < arr.length) {
		if (callback(arr[index], index, arr)) {
			return index;
		}
		index += 1;
	}

	return -1;
}
function arrayFind(array: Dynamic, callback): Dynamic {
	if(TDEF) callback = function type(item: Dynamic, index: Int, array: Array<Dynamic>): Bool {};

	var arr: Array<Dynamic> = array;

	var index = arrayFindIndex(arr, callback);

	return index >= 0 ? arr[index] : null;
}
function arrayMap(array: Dynamic, callback): Array<Dynamic> {
	if(TDEF) callback = function type(item: Dynamic, index: Int, array: Array<Dynamic>): Dynamic {};

	var arr: Array<Dynamic> = array;

	var result = [];

	var index = 0;
	while (index < arr.length) {
		result.push(callback(arr[index], index, arr));

		index += 1;
	}

	return result;
}
function arrayFilter(array: Dynamic, callback): Array<Dynamic> {
	if(TDEF) callback = function type(item: Dynamic, index: Int, array: Array<Dynamic>): Dynamic {};

	var arr: Array<Dynamic> = array;

	var result = [];

	var index = 0;
	while (index < arr.length) {
		if (callback(arr[index], index, arr)) {
			result.push(arr[index]);
		}

		index += 1;
	}

	return result;
}

function arraySort(array: Dynamic, compareFn) {
	if (TDEF) compareFn = function (a: Dynamic, b: Dynamic): Int {};

	var arr: Array<Dynamic> = array;

    var n = arr.length;
	var i = 0;
	while (i < n) {
		var j = 0;
		while (j < n - 1 - i) {
            if (compareFn(arr[j], arr[j + 1]) > 0) {
                var temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
			j++;
        }
		i++;
    }
    return arr;
}

function asAny(value: Dynamic): Any {
	return value;
}

function asDynamic(value: Dynamic): Dynamic {
	return value;
}

function toString(value: Dynamic): String {
	return value + '';
}

function isNull(value: Dynamic): Bool {
	return value == null;
}

function notNull(value: Dynamic): Bool {
	return value != null;
}

function isEqual(a: Dynamic, b: Dynamic): Bool {
	return a == b;
}

function notEqual(a: Dynamic, b: Dynamic): Bool {
	return a != b;
}

// #endregion

// #region Types

//   #region EventEmitter

var TEventKind = TDEF? {
	type: TString,
	payload: function _(payload: Dynamic): Dynamic {},
	TPayload: TDynamic,
} :null;

function FnEventListener (payload: Dynamic): Void {}

var TEventListener = TDEF? {
	type: TString,
	callback: FnEventListener,
} :null;

var TEventData = TDEF? {
	type: TString,
	payload: TDynamic,
} :null;


var _TEventMapItem = TDEF? {
	once: TBool,
	callback: TEventListener.callback,
} :null;
var _TEventMapItemArray = TDEF? (
	[_TEventMapItem]
) :null;

function NewEventEmitter() {
	var eventsMap = makeStringMap();
	if(TDEF) eventsMap.set(TString, _TEventMapItemArray);

	return {
		eventsMap: eventsMap
	}
}

var TEventEmitter = TDEF? (
	NewEventEmitter()
) :null;

function removeEventListener(eventEmitter, eventListener): Void {
	if(TDEF) eventEmitter = TEventEmitter;
	if(TDEF) eventListener = TEventListener;

	var listeners = eventEmitter.eventsMap.get(eventListener.type);

	if (notNull(listeners)) {
		for (data in listeners) {
			if (data.callback == eventListener.callback) {
				listeners.remove(data);
			}
		}
	}
}

function addEventListener(eventEmitter, eventListener, once: Bool): Void {
	if(TDEF) eventEmitter = TEventEmitter;
	if(TDEF) eventListener = TEventListener;


	var listeners = eventEmitter.eventsMap.get(eventListener.type);


	if (isNull(listeners)) {
		listeners = [];
		eventEmitter.eventsMap.set(eventListener.type, listeners);
	}

	listeners.push({
		callback: eventListener.callback,
		once: once,
	});
}

function emitEvent(eventEmitter, eventData): Void {
	if(TDEF) eventEmitter = TEventEmitter;
	if(TDEF) eventData = TEventData;

	var listeners = eventEmitter.eventsMap.get(eventData.type);

	if (listeners != null)  {
		var emitListeners = listeners.copy();
		for (data in emitListeners) {
			FnEventListener = data.callback;
			@async FnEventListener(eventData.payload);

			if (data.once) {
				listeners.remove(data);
			}
		}
	}
}


//   #endregion

// #endregion Types

// #region UI

var TUIQueueNameEnum = TDEF? {queue: TString, pageSize: TInt} :null;

var TUIOrderNameEnum = TDEF? {order: TString, value: TInt} :null;

var TUIListTypeEnum = TDEF? {listType: TString} :null;

// TUIListTypeEnum dict
var UI_LIST_TYPE = {
	ITEM: {listType: 'ITEM'},
	NAV: {listType: 'NAV'},
}

var UI_DEFAULT_PAGE_SIZE = 5;

var UI_RENDER_WAIT = 0.5;

var TUIItem = TDEF? {
	id: TString,
	desc: TString,
	progress: {
		initMax: TFloat,
		initCurrent: TFloat,
	},
	button: {
		name: TString,
		action: TString,
	},
	queueName: TUIQueueNameEnum,
	orderName: TUIOrderNameEnum,
	listType: TUIListTypeEnum,
	initVisible: TBool,
} :null;

var TUIItemMap = TDEF? (function _() {
	var map = makeStringMap();
	map.set(TString, TUIItem);
	return map;
})() :null;

var TUIQueue = TDEF? {
	all: TUIItemMap,
	active: TUIItemMap,
	listAll: [TUIItem],
	listAvailable: TUIItemMap,
	nav: TUIItemMap,
	pageSize: TInt,
	pageOffset: TInt,
} :null;

var TUIQueueMap = TDEF? (function _() {
	var map = makeStringMap();
	map.set(TString, TUIQueue);
	return map;
})() :null;

var TUIPlayerState = TDEF? {
	activeQueue: TUIQueueNameEnum,
	queueMap: TUIQueueMap,
	queueStack: [TUIQueueNameEnum],
} :null;

var TUIPlayerStateMap = TDEF? (function _() {
	var map = makeStringMap();
	map.set(TString, TUIPlayerState);
	return map;
})() :null;

// STATE

var _uiStateMap = TDEF? TUIPlayerStateMap : makeStringMap();

var _uiId: Int = 0;

// METHODS

function uiGetId(): String {
	_uiId = _uiId + 1;
	return 'uiItem' + _uiId;
}

function _uiCreateQueue(pageSize: Int) {
	if(TDEF) return TUIQueue;
	return {
		all: makeStringMap(),
		active: makeStringMap(),
		listAll: [],
		listAvailable: makeStringMap(),
		nav: makeStringMap(),
		pageSize: pageSize == null ? UI_DEFAULT_PAGE_SIZE : pageSize,
		pageOffset: 0,
	}
}

function _uiGetPlayerState(plr: Player) {
	var playerState = _uiStateMap.get(plr.name);
	if (playerState == null) {
		playerState = TDEF? TUIPlayerState : {
			queueMap: makeStringMap(),
			activeQueue: null,
			queueStack: [],
		};
		_uiStateMap.set(plr.name, playerState);
	}

	return playerState;
}

function _uiGetActiveQueueName(plr: Player) {
	var playerState = _uiGetPlayerState(plr);
	return playerState.activeQueue;
}

function _uiGetQueue(plr: Player, queueEnum) {
	if(TDEF) queueEnum = TUIQueueNameEnum;

	var playerState = _uiGetPlayerState(plr);

	var queue = playerState.queueMap.get(queueEnum.queue);
	if (queue == null) {
		queue = _uiCreateQueue(queueEnum.pageSize);
		playerState.queueMap.set(queueEnum.queue, queue);
	}
	return queue;
}

// LIST


var TUIPlayerRenderQueue = TDEF? {
	show: TUIItemMap,
	hide: TUIItemMap,
} :null;
var TUIRenderQueueMap = TDEF? (function _() {
	var map = makeStringMap();
	map.set(TString, TUIPlayerRenderQueue);
	return map;
})() :null;

var _uiRenderQueueMap = TDEF? TUIRenderQueueMap : makeStringMap();

function _uiAddItemToRender(plr: Player, item, visible: Bool) {
	if(TDEF) item = TUIItem;

	var playerRenderQueue = _uiRenderQueueMap.get(plr.name);
	if (playerRenderQueue == null) {
		playerRenderQueue = { show: makeStringMap(), hide: makeStringMap() };
		_uiRenderQueueMap.set(plr.name, playerRenderQueue);
	}

	if (visible) {
		if (!playerRenderQueue.hide.exists(item.id)) {
			playerRenderQueue.show.set(item.id, item);
		}
	} else {
		playerRenderQueue.hide.set(item.id, item);
		if (playerRenderQueue.show.exists(item.id)) {
			playerRenderQueue.show.remove(item.id);
		}
	}
}


var TUIRenderQueueMap = TDEF? (function _() {
	var map = makeStringMap();
	map.set(TString, [TUIPlayerRenderQueue]);
	return map;
})() :null;
var _uiActiveRenderQueueMap = TDEF? TUIRenderQueueMap : makeStringMap();

function _uiApplyRender(plr: Player) {
	var playerRenderQueue = _uiRenderQueueMap.get(player.name);
	if (playerRenderQueue == null) {
		return;
	}
	_uiRenderQueueMap.remove(player.name);

	var activeRenderQueue = _uiActiveRenderQueueMap.get(player.name);
	if (activeRenderQueue == null) {
		activeRenderQueue = [];
		_uiActiveRenderQueueMap.set(player.name, activeRenderQueue);
	}

	activeRenderQueue.push(playerRenderQueue);

	if (activeRenderQueue.length == 1) {
		@async _uiStartRenderer(plr);
	}
}

function _uiStartRenderer(plr: Player) {
	var activeRenderQueue = _uiActiveRenderQueueMap.get(player.name);
	if (activeRenderQueue == null) {
		return;
	}

	while (activeRenderQueue.length > 0) {
		var playerRenderQueue = activeRenderQueue[0];
		var hasRemoved = false;

		@sync for (item in playerRenderQueue.hide) {
			hasRemoved = true;
			@async plr.objectives.setVisible(item.id, false);
		}

		if (hasRemoved) {
			wait(UI_RENDER_WAIT);
		}

		@sync for (item in playerRenderQueue.show) {
			@async plr.objectives.setVisible(item.id, true);
		}

		activeRenderQueue.shift();
	}
}

function _uiListGetAvailableCount(queue) {
	if(TDEF) queue = TUIQueue;

	var count = 0;
	for (item in queue.listAvailable) {
		count++;
	}
	return count;
}

function _uiNormalizePageOffset(queue): Bool {
	if(TDEF) queue = TUIQueue;

	var listItemsCount = _uiListGetAvailableCount(queue);

	if (queue.pageOffset >= listItemsCount) {
		queue.pageOffset = 0;

		return true;
	}

	if (queue.pageOffset < 0) {
		var listItemsCount = _uiListGetAvailableCount(queue);
		var pagesCount = math.max(math.ceil(listItemsCount / queue.pageSize), 1);
		queue.pageOffset = math.floor((pagesCount - 1) * queue.pageSize);

		return true;
	}

	return false;
}

function _uiUpdateActiveQueueList(plr: Player) {
	var activeQueueName = _uiGetActiveQueueName(plr);
	if (activeQueueName == null) {
		return;
	}
	var queue = _uiGetQueue(plr, activeQueueName);
	var counter = 0;

	_uiNormalizePageOffset(queue);

	function applyVisible(item, visible: Bool) {
		if(TDEF) item = TUIItem;

		if (visible) {
			queue.active.set(item.id, item);
		} else {
			queue.active.remove(item.id);
		}

		@async _uiAddItemToRender(plr, item, visible);
	}

	function handleListItem(item) {
		if(TDEF) item = TUIItem;

		var active = queue.active.exists(item.id);
		var available = queue.listAvailable.exists(item.id);
		if (!available) {
			if (active) {
				@async applyVisible(item, false);
			}
			return;
		}

		var nextActive = counter >= queue.pageOffset && counter < (queue.pageOffset + queue.pageSize);

		if (active != nextActive) {
			@async applyVisible(item, nextActive);
		}

		counter++;
	}
	@sync for (item in queue.listAll) {
		@async handleListItem(item);
	}

	var hasPages = counter > queue.pageSize;
	var pagesCount = math.ceil(counter / queue.pageSize);
	var currentPage = math.floor(queue.pageOffset / queue.pageSize) + 1;

	function handleNavItem(item) {
		if(TDEF) item = TUIItem;

		var active = queue.active.exists(item.id);

		if (active != hasPages) {
			@async applyVisible(item, hasPages);
		}
		if (hasPages && item.progress != null) {
			@async plr.objectives.setGoalVal(item.id, pagesCount);
			@async plr.objectives.setCurrentVal(item.id, currentPage);
		}
	}
	@sync for (item in queue.nav) {
		@async handleNavItem(item);
	}
}

function _uiSetItemVisible(plr: Player, item, visible: Bool): Void {
	if(TDEF) item = TUIItem;

	var activeQueueName = _uiGetActiveQueueName(plr);
	var itemQueue = _uiGetQueue(plr, item.queueName);
	var currentVisible = itemQueue.active.exists(item.id);

	if (currentVisible != visible) {
		if (visible) {
			itemQueue.active.set(item.id, item);
		} else {
			itemQueue.active.remove(item.id);
		}

		if (activeQueueName != null && item.queueName == activeQueueName) {
			@async _uiAddItemToRender(plr, item, visible);
		}
	}
}

function _uiSetListItemVisible(plr: Player, item, visible: Bool): Void {
	if(TDEF) item = TUIItem;

	var itemQueue = _uiGetQueue(plr, item.queueName);
	var currentAvailable = itemQueue.listAvailable.exists(item.id);

	if (currentAvailable != visible) {
		if (visible) {
			itemQueue.listAvailable.set(item.id, item);
		} else {
			itemQueue.listAvailable.remove(item.id);
		}
	}
}


function uiSetItemsVisible(plr: Player, items, visible: Bool): Void {
	if(TDEF) items = [TUIItem];

	var activeQueueName = _uiGetActiveQueueName(plr);
	var hasListType = false;

	@sync for (item in items) {
		if (item.listType != null && item.queueName == activeQueueName) {
			hasListType = true;
		}
		if (item.listType == UI_LIST_TYPE.ITEM) {
			@async _uiSetListItemVisible(plr, item, visible);
		} else {
			@async _uiSetItemVisible(plr, item, visible);
		}
	}

	if (hasListType) {
		@async _uiUpdateActiveQueueList(plr);
	}

	@async _uiApplyRender(plr);
}

function uiGetItemVisible(plr: Player, item) {
	if(TDEF) item = TUIItem;

	var queue = _uiGetQueue(plr, item.queueName);
	if (queue == null) {
		return false;
	}

	if (item.listType == UI_LIST_TYPE.ITEM) {
		return queue.listAvailable.exists(item.id);
	}

	return queue.active.exists(item.id);
}

function uiSetActiveQueue(plr: Player, queueName) {
	if(TDEF) queueName = TUIQueueNameEnum;

	var playerState = _uiGetPlayerState(plr);
	if (playerState.activeQueue != queueName) {
		var activeQueueName = _uiGetActiveQueueName(plr);

		if (activeQueueName != null) {
			var activeQueue = _uiGetQueue(plr, activeQueueName);
			@sync for (item in activeQueue.active) {
				@async _uiAddItemToRender(plr, item, false);
			}
		}

		var nextQueue = _uiGetQueue(plr, queueName);
		@sync for (item in nextQueue.active) {
			@async _uiAddItemToRender(plr, item, true);
		}
		playerState.activeQueue = queueName;

		@async _uiUpdateActiveQueueList(plr);

		@async _uiApplyRender(plr);
	}
}

function uiAddActiveQueue(plr: Player, queueName) {
	if(TDEF) queueName = TUIQueueNameEnum;


	var playerState = _uiGetPlayerState(plr);
	if (playerState.activeQueue != null && playerState.activeQueue != queueName) {
		playerState.queueStack.push(playerState.activeQueue);

		@async uiSetActiveQueue(plr, queueName);
	}
}

function uiBackActiveQueue(plr: Player) {
	var playerState = _uiGetPlayerState(plr);
	if (playerState.queueStack.length > 0) {
		var queueName = playerState.queueStack.pop();

		@async uiSetActiveQueue(plr, queueName);
	}
}

function uiGetActiveQueue(plr: Player) {
	return _uiGetActiveQueueName(plr);
}

function uiListNextPage(plr: Player) {
	var activeQueueName = _uiGetActiveQueueName(plr);
	if (activeQueueName == null) {
		return;
	}
	var queue = _uiGetQueue(plr, activeQueueName);
	var listItemsCount = _uiListGetAvailableCount(queue);

	queue.pageOffset += queue.pageSize;

	_uiNormalizePageOffset(queue);

	@async _uiUpdateActiveQueueList(plr);

	@async _uiApplyRender(plr);
}

function uiListPrevPage(plr: Player) {
	var activeQueueName = _uiGetActiveQueueName(plr);
	if (activeQueueName == null) {
		return;
	}
	var queue = _uiGetQueue(plr, activeQueueName);

	queue.pageOffset -= queue.pageSize;

	_uiNormalizePageOffset(queue);

	@async _uiUpdateActiveQueueList(plr);

	@async _uiApplyRender(plr);
}


var TUIOrder = TDEF? {
	value: TInt,
	items: [TUIItem]
} :null;
var TUIOrderMap = TDEF? (function _() {
	var map = makeStringMap();
	map.set(TString, TUIOrder);
	return map;
})() :null;

var _uiOrderMap = TDEF? TUIOrderMap : makeStringMap();

function _uiInitItem(plr: Player, item) {
	if (TDEF) item = TUIItem;

	var order = _uiOrderMap.get(item.orderName.order);
	if (order == null) {
		order = {
			value: item.orderName.value,
			items: [],
		};
		_uiOrderMap.set(item.orderName.order, order);
	}
	order.items.push(item);


	var queue = _uiGetQueue(plr, item.queueName);
	queue.all.set(item.id, item);

	if (item.initVisible && item.listType == null) {
		queue.active.set(item.id, item);
	}

	if (item.listType != null) {
		if (item.listType == UI_LIST_TYPE.ITEM) {
			queue.listAll.push(item);

			if (item.initVisible) {
				queue.listAvailable.set(item.id, item);
			}
		}
		if (item.listType == UI_LIST_TYPE.NAV) {
			queue.nav.set(item.id, item);
		}
	}
}

function uiAddItem(item) {
	if(TDEF) item = TUIItem;

	if (item.id == null) {
		item.id = uiGetId();
	}

	@sync for (plr in state.players) {
		if (plr.isAI) {
			continue;
		}

		@async _uiInitItem(plr, item);
	}

	return item;
}

function uiApplyOrderItems(activeQueueName) {
	if (TDEF) activeQueueName = TUIQueueNameEnum;

	var orders = TDEF? [TUIOrder] : [];
	for (order in _uiOrderMap) {
		orders.insert(order.value, order);
	}
	arraySort(orders, function _(a, b): Int {
		var ta = TDEF? TUIOrder : a;
		var tb = TDEF? TUIOrder : b;

		return ta.value - tb.value;
	});

	@sync {
		for (plr in state.players) {
			if (plr.isAI) {
				continue;
			}

			for (order in orders) {
				for (item in order.items) {
					var visible = (
						item.initVisible &&
						item.queueName.queue == activeQueueName.queue &&
						item.listType == null
					);


					@async plr.objectives.add(
						item.id,
						item.desc,
						{
							visible: visible,
							val: item.progress != null ? item.progress.initCurrent : null,
							goalVal: item.progress != null ? item.progress.initMax : null,
							showProgressBar: item.progress != null,
							showOtherPlayers: false,
						},
						item.button
					);
					// for some reason "val" in add() fn doesn't work
					if (item.progress != null && item.progress.initCurrent != null) {
						@async plr.objectives.setCurrentVal(item.id, item.progress.initCurrent);
					}
				}
			}
		}
	}

	for (playerState in _uiStateMap) {
		playerState.activeQueue = activeQueueName;
	}

	@sync for (plr in state.players) {
		if (!plr.isAI) {
			@async _uiUpdateActiveQueueList(plr);

			@async _uiApplyRender(plr);
		}
	}
}

// #endregion UI

// #region Net

function _netArgs1(arg1: Dynamic): Array<Dynamic> {
	return [arg1];
}
function _netArgs2(arg1: Dynamic, arg2: Dynamic): Array<Dynamic> {
	return [arg1, arg2];
}
function _netArgs3(arg1: Dynamic, arg2: Dynamic, arg3: Dynamic): Array<Dynamic> {
	return [arg1, arg2, arg3];
}

function netMoveCamera(plr: Player, target: {x: Float, y: Float}, speed: Float) {
	invoke(plr, '_netMoveCamera', _netArgs2(target, speed));
}
function netMoveCameraAll(target: {x: Float, y: Float}, speed: Float) {
	invokeAll('_netMoveCamera', _netArgs2(target, speed));
}
function _netMoveCamera(target: {x: Float, y: Float}, speed: Float) {
	@async moveCamera(target, speed);
}


function netGenericNotify(plr: Player, text: String, target: Entity) {
	invoke(plr, '_netGenericNotify', _netArgs2(text, target));
}
function netGenericNotifyAll(text: String, target: Entity) {
	invokeAll('_netGenericNotify', _netArgs2(text, target));
}
function _netGenericNotify(text: String, target: Entity) {
	me().genericNotify(text, target);
}

function netSfx(plr: Player, sfxKind: UiSfxKind, volume: Float) {
	invoke(plr, '_netSfx', _netArgs2(sfxKind, volume));
}
function netSfxAll(sfxKind: UiSfxKind, volume: Float) {
	invokeAll('_netSfx', _netArgs2(sfxKind, volume));
}
function _netSfx(sfxKind: UiSfxKind, volume: Float) {
	sfx(sfxKind, volume);
}

function netUiSetActiveQueue(plr: Player, queueName) {
	if(TDEF) queueName = TUIQueueNameEnum;

	invokeHost('_netUiSetActiveQueue', _netArgs2(plr, queueName));
}
function _netUiSetActiveQueue(plr: Player, queueName) {
	if(TDEF) queueName = TUIQueueNameEnum;

	uiSetActiveQueue(plr, queueName);
}

function netUiAddActiveQueue(plr: Player, queueName) {
	if(TDEF) queueName = TUIQueueNameEnum;

	invokeHost('_netUiAddActiveQueue', _netArgs2(plr, queueName));
}
function _netUiAddActiveQueue(plr: Player, queueName) {
	if(TDEF) queueName = TUIQueueNameEnum;

	uiAddActiveQueue(plr, queueName);
}

var BTN_UI_NEXT_PAGE = 'btnUiNextPage';
function btnUiNextPage() {
	invokeHost('_netUiNextPage', _netArgs1(me()));
}
function _netUiNextPage(plr: Player) {
	@async uiListNextPage(plr);
}

var BTN_UI_BACK = 'btnUiBackPage';
function btnUiBackPage() {
	invokeHost('_netUiBack', _netArgs1(me()));
}
function _netUiBack(plr: Player) {
	@async uiBackActiveQueue(plr);
}

// #endregion Net

// #region Effects And Sounds

function effectExplosion(zone: Zone, entity: Entity) {
	wait(0.01);
	var building = zone.createBuilding(Building.MagmaFlow, false, {pos: entity});
	wait(0.01);
	building.destroy();
}

var TUnitSound = TDEF? {
	unit: TUnitKind,
	sfx: TString,
} :null;
function playUnitSound(sound, zone: Zone, entity: Entity) {
	if(TDEF) sound = TUnitSound;

	if (entity == null) entity = zone;
	var unit = spawnUnit(zone, null, sound.unit, entity.x, entity.y);

	unit.sfx(sound.sfx);
	wait(0.01);
	unit.remove();
}

var TGlobalSound = TDEF? {
	uiSfx: TUiSfxKind,
	unitSfx: TUnitSound,
	volume: TFloat,
} :null;
function playGlobalSound(sound, zone: Zone, entity: Entity) {
	if(TDEF) sound = TGlobalSound;

	if (sound.uiSfx != null) {
		netSfxAll(sound.uiSfx, sound.volume);
	} else if (sound.unitSfx != null) {
		@async playUnitSound(sound.unitSfx, zone, entity);
	}
}

var UnitSoundWolf = TUnitSound;
UnitSoundWolf = {
	unit: Unit.Wolf,
	sfx: 'bite',
};

// #endregion

// #region Global Constants

var UI_QUEUE = {
	INIT: TDEF? TUIQueueNameEnum
		:{queue: 'INIT', pageSize: null},
	SELECT_HERO: TDEF? TUIQueueNameEnum
		:{queue: 'SELECT_HERO', pageSize: 8},
	HUB: TDEF? TUIQueueNameEnum
		:{queue: 'HUB', pageSize: null},
	MAIN: TDEF? TUIQueueNameEnum
		:{queue: 'MAIN', pageSize: null},
	UPGRADE_ABILITIES: TDEF? TUIQueueNameEnum
		:{queue: 'UPGRADE_ABILITIES', pageSize: null},
	SHOP: TDEF? TUIQueueNameEnum
		:{queue: 'SHOP', pageSize: 5},
}

var UI_ORDER = {
	HEADER: TDEF? TUIOrderNameEnum
		:{order: 'HEADER', value: 1},
	BODY: TDEF? TUIOrderNameEnum
		:{order: 'ABILITY', value: 2},
	LIST_NAV: TDEF? TUIOrderNameEnum
		:{order: 'LIST_NAV', value: 4},
	FOOTER: TDEF? TUIOrderNameEnum
		:{order: 'FOOTER', value: 5},
}

var MAX_ABILITY_LEVEL = 4;

var CDB = {
	XP_PER_LEVEL: 200,
	POWER_PERCENT_PER_FAME: 1,
}

var CONFIG = {
	START_LIVES: 3,
	DIFFICULTY_MAP: [1, 2.2, 4, 6],
	HERO_REVIVE_COOLDOWN_SEC: 5,
	POWER_PERCENT_PER_LEVEL: 10,
	ABILITY_UPGRADE_COST: 1,
	ABILITY_UPGRADE_RES: Resource.Stone,
}

// #endregion Global Constants

// #region Global Variables

var ZONES = {
	INIT_WATER: getZone(310),
	INIT: getZone(296),
}

var USER_PLAYERS: Array<Player> = [];
var ALLY_PLAYER: Player;
var FOE_PLAYER: Player;

var PLAYER_MAIN_ZONE_MAP = makeStringMap();
function getPlayerMainZone(plr: Player): Zone {
	return PLAYER_MAIN_ZONE_MAP.get(plr.name);
}

var DIFFICULTY_MOD: Float;

var UI_ITEMS = TDEF? [TUIItem] : [];

var gameEvents = TEventEmitter;

function setupGlobalVars() {
	gameEvents = NewEventEmitter();

	@sync for (plr in state.players) {
		@async plr.setModifierFlag(PlayerModifierFlag.NoConsumption);
		// @async plr.setModifierFlag(PlayerModifierFlag.NoVillagerSpawn);

		if (plr.isAI) {
			@async plr.setAIFlag(PlayerAIFlag.NoBuilding);
			@async plr.setAIFlag(PlayerAIFlag.NoBuild);
			@async plr.setAIFlag(PlayerAIFlag.NoHero);
			@async plr.setAIFlag(PlayerAIFlag.NoMilitary);
			@async plr.setAIFlag(PlayerAIFlag.NoTechLearn);
			@async plr.setAIFlag(PlayerAIFlag.NoAssign);
		}

		if (!plr.isAI) {
			USER_PLAYERS.push(plr);
		}
		if (plr.isAI && plr.isPlayer() && !plr.team.asPlayer().isAI) {
			ALLY_PLAYER = plr;
		}
		if (plr.isAI && plr.isPlayer() && plr.team.asPlayer().isAI) {
			FOE_PLAYER = plr;
		}
		PLAYER_MAIN_ZONE_MAP.set(plr.name, player.zones.copy()[0]);
	}

	DIFFICULTY_MOD = CONFIG.DIFFICULTY_MAP[USER_PLAYERS.length - 1];
}


// Global events

var GlobalEventUpdateType = 'global:update';
var TGlobalEventUpdatePayload = TDEF? {elapsed: TFloat} :null;
function GlobalEventUpdateListener (callback) {
	if(TDEF) callback = function _(payload): Void { payload = TGlobalEventUpdatePayload; };
	if(TDEF) return TEventListener;
	return {
		type: GlobalEventUpdateType,
		callback: callback,
	}
}
function GlobalEventUpdateData(payload) {
	if(TDEF) payload = TGlobalEventUpdatePayload;
	if(TDEF) return TEventData;
	return {
		type: GlobalEventUpdateType,
		payload: payload,
	};
}

function onUpdate(callback) {
	if(TDEF) callback = function _(elapsed: Float, stop) { stop = function _(){}; };
	var eventListener = TDEF? GlobalEventUpdateListener(null) :null;

	function stop() {
		removeEventListener(gameEvents, eventListener);
	}

	eventListener = GlobalEventUpdateListener(
		function _(payload) {
			callback(payload.elapsed, stop);
		}
	);

	addEventListener(gameEvents, eventListener, false);

	return eventListener;
}

function stopUpdate(eventListener) {
	if (TDEF) eventListener = GlobalEventUpdateListener(null);

	if (eventListener != null) {
		removeEventListener(gameEvents, eventListener);
	}
}

// #endregion


// #region Hero Class

var THeroPartial = TDEF? {
	unitKind: TUnitKind,
	player: TPlayer,
	unit: TUnit,
	events: TEventEmitter,

	isAlive: TBool,
	lastZone: TZone,
	level: TInt,
} :null;


var THeroAbilityConfig = TDEF? {
	costRes: TResourceKind,
	costAmount: TInt,
	cooldown: TFloat,
	duration: TFloat,
	description: TString,
} :null;

function FnHeroAbilityConfigByLevel(level: Int) { return THeroAbilityConfig; }

function FnHeroAbilityActivate(level: Int, duration: Float): Void {}
function FnHeroAbilityUpgrade(level: Int): Void {}

var HERO_ABILITY_STATE = {
	READY: 'READY',
	ACTIVE: 'ACTIVE',
	COOLDOWN: 'COOLDOWN'
}

var THeroAbilityCommonParams = TDEF? {
	name: TString,
	passive: TBool,
	sound: TGlobalSound,
	configByLevel: FnHeroAbilityConfigByLevel,
	// added on setup
	uiItemByLevelIndex: [TUIItem],
	uiUpgradeItem: TUIItem,
} :null;

var THeroAbility = TDEF? {
	params: THeroAbilityCommonParams,

	state: TString,
	level: TInt,
	activeUntil: TFloat,
	cooldownUntil: TFloat,

	activate: FnHeroAbilityActivate,
	upgrade: FnHeroAbilityUpgrade,
} :null;

var THeroAbilityCallbacks = {
	activate: FnHeroAbilityActivate,
	upgrade: FnHeroAbilityUpgrade,
}

function FnHeroAbilityCreate (hero, params) {
	hero = THeroPartial;
	params = THeroAbilityCommonParams;
	return THeroAbilityCallbacks;
}

var THeroAbilityParams = TDEF? {
	common: THeroAbilityCommonParams,
	create: FnHeroAbilityCreate,
} :null;

function NewHeroAbility(abilityParams, hero) {
	if(TDEF) abilityParams = THeroAbilityParams;
	if(TDEF) hero = THeroPartial;
	if(TDEF) return THeroAbility;

	FnHeroAbilityCreate = abilityParams.create;
	var callbacks = FnHeroAbilityCreate(hero, abilityParams.common);

	return {
		params: abilityParams.common,

		state: HERO_ABILITY_STATE.READY,
		level: 1,
		activeUntil: null,
		cooldownUntil: null,

		activate: callbacks.activate,
		upgrade: callbacks.upgrade,
	}
}

// utils

function intByLevel(level: Int, values: Array<Int>): Int {
	var levelIndex = level - 1;
	return values[levelIndex];
}
function floatByLevel(level: Int, values: Array<Float>): Float {
	var levelIndex = level - 1;
	return values[levelIndex];
}

// Hero ability

function heroAbilityParamsGetConfig(abilityParams, level: Int) {
	if(TDEF) abilityParams = THeroAbilityCommonParams;

	FnHeroAbilityConfigByLevel = abilityParams.configByLevel;
	return FnHeroAbilityConfigByLevel(level);
}

function heroAbilityGetConfig(ability) {
	if(TDEF) ability = THeroAbility;

	return heroAbilityParamsGetConfig(ability.params, ability.level);
}

function _heroAbilityGetNextState(ability) {
	if(TDEF) ability = THeroAbility;

	if (ability.activeUntil != null && ability.activeUntil > state.time) {
		return HERO_ABILITY_STATE.ACTIVE;
	}
	if (ability.cooldownUntil != null && ability.cooldownUntil > state.time) {
		return HERO_ABILITY_STATE.COOLDOWN;
	}

	return HERO_ABILITY_STATE.READY;
}

function _heroAbilityProcessState(hero, ability, config) {
	if(TDEF) hero = THeroPartial;
	if(TDEF) ability = THeroAbility;
	if(TDEF) config = THeroAbilityConfig;

	var uiItem = ability.params.uiItemByLevelIndex[ability.level - 1];

	var nextState = _heroAbilityGetNextState(ability);

	if (nextState != ability.state) {
		switch (nextState) {
			case HERO_ABILITY_STATE.READY:
				@async hero.player.objectives.setGoalVal(uiItem.id, 1);
				@async hero.player.objectives.setCurrentVal(uiItem.id, 1);
				@async hero.player.objectives.setStatus(uiItem.id, OStatus.Empty);
			case HERO_ABILITY_STATE.ACTIVE:
				@async hero.player.objectives.setGoalVal(uiItem.id, config.duration);
				@async hero.player.objectives.setStatus(uiItem.id, OStatus.Done);
			case HERO_ABILITY_STATE.COOLDOWN:
				@async hero.player.objectives.setGoalVal(uiItem.id, config.cooldown);
				@async hero.player.objectives.setStatus(uiItem.id, OStatus.Missed);
		}
		ability.state = nextState;
	}

	switch (ability.state) {
		case HERO_ABILITY_STATE.ACTIVE:
			var value = math.max(0, ability.activeUntil - state.time);
			@async hero.player.objectives.setCurrentVal(uiItem.id, value);
		case HERO_ABILITY_STATE.COOLDOWN:
			var value = math.max(0, ability.cooldownUntil - state.time);
			@async hero.player.objectives.setCurrentVal(uiItem.id, value);
	}
}

function _heroAbilityActivate(hero, ability) {
	if(TDEF) hero = THeroPartial;
	if(TDEF) ability = THeroAbility;

	if (ability.state != HERO_ABILITY_STATE.READY || ability.activate == null || !hero.isAlive) {
		return;
	}

	var config = heroAbilityGetConfig(ability);

	if (config.cooldown != null) {
		ability.cooldownUntil = state.time + config.cooldown;
	}
	if (config.duration != null) {
		ability.activeUntil = state.time + config.duration;
	}

	_heroAbilityProcessState(hero, ability, config);

	onUpdate(function _(elapsed, stop) {
		_heroAbilityProcessState(hero, ability, config);

		if (ability.state == HERO_ABILITY_STATE.READY) {
			stop();
		}
	});

	FnHeroAbilityActivate = ability.activate;
	@async FnHeroAbilityActivate(ability.level, config.duration);
}

function _heroAbilityUpgrade(hero, ability) {
	if(TDEF) hero = THeroPartial;
	if(TDEF) ability = THeroAbility;

	if (ability.level >= MAX_ABILITY_LEVEL) {
		return;
	}

	var prevLevel = ability.level;
	var nextLevel = prevLevel + 1;

	ability.level = nextLevel;

	@async hero.player.objectives.setCurrentVal(ability.params.uiUpgradeItem.id, nextLevel);
	if (nextLevel >= MAX_ABILITY_LEVEL) {
	@async hero.player.objectives.setStatus(ability.params.uiUpgradeItem.id, OStatus.Done);
	}

	@async uiSetItemsVisible(hero.player, [ability.params.uiItemByLevelIndex[prevLevel - 1]], false);
	@async uiSetItemsVisible(hero.player, [ability.params.uiItemByLevelIndex[nextLevel - 1]], true);

	if (ability.upgrade != null) {
		FnHeroAbilityUpgrade = ability.upgrade;
		@async FnHeroAbilityUpgrade(nextLevel);
	}
}

function FnHeroParamsInit(hero) {
	hero = THeroPartial;
}

var THeroParams = TDEF? {
	id: TString,
	unitKind: TUnitKind,
	description: TString,
	abilities: [THeroAbilityParams],
	init: FnHeroParamsInit,
	selectAction: TString,

	// added on setup
	selectUiItem: TUIItem,
} :null;

var THero = TDEF? {
	params: THeroParams,

	unitKind: TUnitKind,

	player: TPlayer,
	unit: TUnit,

	abilities: [THeroAbility],

	events: TEventEmitter,

	// state
	isAlive: TBool,
	lastZone: TZone,
	level: TInt,
} :null;

// Hero Events

var HeroEventDieType = 'hero:die';
var THeroEventDiePayload = TDEF? { hero: THero, canRevive: TBool, zone: TZone } :null;
function HeroEventDieListener (callback) {
	if(TDEF) callback = function _(payload): Void { payload = THeroEventDiePayload; };
	if(TDEF) return TEventListener;
	return {
		type: HeroEventDieType,
		callback: callback,
	}
}
function HeroEventDieData(payload) {
	if(TDEF) payload = THeroEventDiePayload;
	if(TDEF) return TEventData;
	return {
		type: HeroEventDieType,
		payload: payload,
	};
}

var HeroEventReviveType = 'hero:revive';
var THeroEventRevivePayload = TDEF? { hero: THero, zone: TZone } :null;
function HeroEventReviveListener (callback) {
	if(TDEF) callback = function _(payload): Void { payload = THeroEventRevivePayload; };
	if(TDEF) return TEventListener;
	return {
		type: HeroEventReviveType,
		callback: callback,
	}
}
function HeroEventReviveData(payload) {
	if(TDEF) payload = THeroEventRevivePayload;
	if(TDEF) return TEventData;
	return {
		type: HeroEventReviveType,
		payload: payload,
	};
}

var HeroEventLevelUpType = 'hero:levelUp';
var THeroEventLevelUpPayload = TDEF? { hero: THero } :null;
function HeroEventLevelUpListener (callback) {
	if(TDEF) callback = function _(payload): Void { payload = THeroEventLevelUpPayload; };
	if(TDEF) return TEventListener;
	return {
		type: HeroEventLevelUpType,
		callback: callback,
	}
}
function HeroEventLevelUpData(payload) {
	if(TDEF) payload = THeroEventLevelUpPayload;
	if(TDEF) return TEventData;
	return {
		type: HeroEventLevelUpType,
		payload: payload,
	};
}

var HeroEventZoneChangeType = 'hero:zoneChange';
var THeroEventZoneChangePayload = TDEF? { hero: THero, prevZone: TZone } :null;
function HeroEventZoneChangeListener (callback) {
	if(TDEF) callback = function _(payload): Void { payload = THeroEventZoneChangePayload; };
	if(TDEF) return TEventListener;
	return {
		type: HeroEventZoneChangeType,
		callback: callback,
	}
}
function HeroEventZoneChangeData(payload) {
	if(TDEF) payload = THeroEventZoneChangePayload;
	if(TDEF) return TEventData;
	return {
		type: HeroEventZoneChangeType,
		payload: payload,
	};
}

// Hero Init


function _heroRevive(hero) {
	if(TDEF) hero = THero;

	if (hero.isAlive || hero.lastZone == null) {
		return;
	}

	hero.unit = hero.lastZone.addUnit(hero.params.unitKind, 1, hero.player, true)[0];
	hero.isAlive = true;

	@async netMoveCamera(hero.player, {x: hero.unit.x, y: hero.unit.y}, null);

	for (plr in USER_PLAYERS) {
		var volume = plr == hero.player ? 5 : 1;
		@async netSfx(plr, UiSfx.EndGameFameVictory, volume);
	}

	var eventData = HeroEventReviveData({hero: hero, zone: hero.lastZone });
	@async emitEvent(hero.events, eventData);
	@async emitEvent(gameEvents, eventData);
}

function _heroDie(hero) {
	if(TDEF) hero = THero;

	if (!hero.isAlive) {
		return;
	}
	var zone = hero.lastZone;
	var canRevive = hero.player.getResource(Resource.Gemstone) > 0;

	hero.unit = null;
	hero.isAlive = false;

	for (plr in USER_PLAYERS) {
		var volume = plr == hero.player ? 5 : 1;
		@async netSfx(plr, UiSfx.DeathmatchHeroDies, volume);
	}

	if (canRevive) {
		netGenericNotify(hero.player, 'You died, spent 1[Gemstone] and revive in ' + CONFIG.HERO_REVIVE_COOLDOWN_SEC + ' seconds!', zone);
	} else {
		netGenericNotify(hero.player, 'You died, but has no lives to revive! Wait until your allies clean stage!', zone);
	}

	if (canRevive) {
		hero.player.addResource(Resource.Gemstone, -1);
	}

	// cleanup auto revive from rule WarchiefElimination
	var autoreviveUnit = getPlayerMainZone(hero.player).getUnit(hero.params.unitKind);
	if (autoreviveUnit != null) {
		autoreviveUnit.remove();
	}

	var eventData = HeroEventDieData({hero: hero, canRevive: canRevive, zone: hero.lastZone });
	@async emitEvent(hero.events, eventData);
	@async emitEvent(gameEvents, eventData);

	if (canRevive) {
		wait(CONFIG.HERO_REVIVE_COOLDOWN_SEC);
		_heroRevive(hero);
	}
}

function _heroLevelUp(hero) {
	if(TDEF) hero = THero;

	if (hero.level * CDB.XP_PER_LEVEL > hero.player.getResource(Resource.MilitaryXP)) {
		return;
	}

	hero.level += 1;

	hero.player.addResource(Resource.Fame, CONFIG.POWER_PERCENT_PER_LEVEL * CDB.POWER_PERCENT_PER_FAME);

	netGenericNotify(
		hero.player,
		"Level up!\n" +
			"Attack power of your units increased by " + CONFIG.POWER_PERCENT_PER_LEVEL + "%",
		hero.unit
	);

	@async netSfx(hero.player, UiSfx.StartGame, 5);

	var eventData = HeroEventLevelUpData({hero: hero});
	@async emitEvent(hero.events, eventData);
	@async emitEvent(gameEvents, eventData);
}

function NewHero(heroParams, plr: Player, unit: Unit) {
	if(TDEF) heroParams = THeroParams;
	if(TDEF) return THero;

	var hero = THero;
	hero = {
		params: heroParams,

		unitKind: heroParams.unitKind,

		player: plr,
		unit: unit,

		abilities: [],

		events: NewEventEmitter(),

		isAlive: true,
		lastZone: unit.zone,
		level: 1,
	}

	for (abilityParams in hero.params.abilities) {
		hero.abilities.push(
			NewHeroAbility(abilityParams, hero)
		);
	}

	var uiItems = [
		for (ability in hero.abilities) ability.params.uiItemByLevelIndex[0]
	].concat([
		for (ability in hero.abilities) ability.params.uiUpgradeItem
	]);
	@async uiSetItemsVisible(hero.player, uiItems, true);

	if (heroParams.init != null) {
		FnHeroParamsInit = heroParams.init;
		@async FnHeroParamsInit(hero);
	}

	onUpdate(function _(elapsed, stop) {
		if (hero.unit != null && hero.unit.zone != null) {
			var prevZone = hero.lastZone;
			hero.lastZone = hero.unit.zone;

			if (prevZone != null) {
				var eventData = HeroEventZoneChangeData({hero: hero, prevZone: prevZone});
				@async emitEvent(hero.events, eventData);
				@async emitEvent(gameEvents, eventData);
			}
		}
		if (hero.isAlive && hero.unit != null) {
			if (hero.unit.isRemoved()) {
				@async _heroDie(hero);
			}
		}
		if (
			hero.isAlive &&
			hero.level * CDB.XP_PER_LEVEL < hero.player.getResource(Resource.MilitaryXP)
		) {
			@async _heroLevelUp(hero);
		}
	});

	return hero;
}

function heroActivateAbility(hero, abilityIndex: Int) {
	if(TDEF) hero = THero;

	var ability = hero.abilities[abilityIndex];

	if (ability == null) {
		log('Ability to activate with index ' + abilityIndex + ' for hero ' + hero.params.id + ' not found');
		return;
	}

	if (!hero.isAlive) {
		netGenericNotify(hero.player, 'You can\'t use abilities while dead', null);
		return;
	}

	if (ability.state != HERO_ABILITY_STATE.READY) {
		netGenericNotify(hero.player, 'Ability "' + ability.params.name + '" is not ready!', null);
		return;
	}

	var config = heroAbilityGetConfig(ability);
	if (hero.player.getResource(config.costRes) < config.costAmount) {
		netGenericNotify(hero.player, 'You need ' + config.costAmount + txtBr(config.costRes) + ' to activate "' + ability.params.name + '" ability!', null);
		return;
	}
	@async hero.player.addResource(config.costRes, config.costAmount * -1);

	@async _heroAbilityActivate(hero, ability);

	if (ability.params.sound != null) {
		@async playGlobalSound(ability.params.sound, hero.lastZone, hero.unit);
	}

}

function heroUpgradeAbility(hero, abilityIndex: Int) {
	if(TDEF) hero = THero;

	var ability = hero.abilities[abilityIndex];

	if (ability == null) {
		log('Ability to upgrade with index ' + abilityIndex + ' for hero ' + hero.params.id + ' not found');
		return;
	}

	if (ability.level >= MAX_ABILITY_LEVEL) {
		netGenericNotify(hero.player, 'Ability "' + ability.params.name + '" already has max level!', null);
		return;
	}

	if (hero.player.getResource(CONFIG.ABILITY_UPGRADE_RES) < CONFIG.ABILITY_UPGRADE_COST) {
		netGenericNotify(hero.player, 'You need ' + CONFIG.ABILITY_UPGRADE_COST + txtBr(CONFIG.ABILITY_UPGRADE_RES) + ' to upgrade "' + ability.params.name + '" ability!', null);
		return;
	}
	@async hero.player.addResource(CONFIG.ABILITY_UPGRADE_RES, CONFIG.ABILITY_UPGRADE_COST * -1);

	@async netSfx(hero.player, UiSfx.ForgeSword, 5);

	@async _heroAbilityUpgrade(hero, ability);
}

// Global Vars

var HEROES_PARAMS = TDEF? [THeroParams] : [];

var HEROES = TDEF? [THero] : [];

function getHeroByPlayer(plr: Player) {
	for (hero in HEROES) {
		if (hero.player == plr) {
			return hero;
		}
	}
	return null;
}

function netActivateAbility(plr: Player, abilityIndex: Int) {
	invokeHost('_netActivateAbility', _netArgs2(plr, abilityIndex));
}
function _netActivateAbility(plr: Player, abilityIndex: Int) {
	var hero = getHeroByPlayer(plr);
	if (hero != null) {
		heroActivateAbility(hero, abilityIndex);
	}
}

function netUpgradeAbility(plr: Player, abilityIndex: Int) {
	invokeHost('_netUpgradeAbility', _netArgs2(plr, abilityIndex));
}
function _netUpgradeAbility(plr: Player, abilityIndex: Int) {
	var hero = getHeroByPlayer(plr);
	if (hero != null) {
		heroUpgradeAbility(hero, abilityIndex);
	}
}

function netSelectHero(plr: Player, hero) {
	if(TDEF) hero = THeroParams;

	invokeHost('_netSelectHero', _netArgs2(plr, hero.id));
}
function _netSelectHero(plr: Player, heroId: String) {
	if (getHeroByPlayer(plr) != null) {
		return;
	}

	for (hero in HEROES) {
		if (hero.params.id == heroId) {
			return;
		}
	}

	function handleHero(heroParams) {
		if(TDEF) heroParams = THeroParams;

		drakkar(me(), ZONES.INIT, ZONES.INIT_WATER, 0, 0, [heroParams.unitKind]);
		var unit = plr.getUnit(heroParams.unitKind);

		HEROES.push(
			NewHero(heroParams, plr, unit)
		);

		@sync for (plr in USER_PLAYERS) {
			@async plr.objectives.setStatus(heroParams.selectUiItem.id, OStatus.Missed);
		}

		@async uiSetActiveQueue(plr, UI_QUEUE.MAIN);
	}

	@sync for (heroParams in HEROES_PARAMS) {
		if (heroParams.id == heroId) {
			@async handleHero(heroParams);
			return;
		}
	}
}

// Hero Prepare UI

var BTN_ACTIVATE_ABILITY_BASE = 'btnActivateAbility';
function btnActivateAbility0() {
	netActivateAbility(me(), 0);
}
function btnActivateAbility1() {
	netActivateAbility(me(), 0);
}
function btnActivateAbility2() {
	netActivateAbility(me(), 0);
}
function btnActivateAbility3() {
	netActivateAbility(me(), 0);
}
function btnActivateAbility4() {
	netActivateAbility(me(), 0);
}

var BTN_UPGRADE_ABILITY_BASE = 'btnUpgradeAbility';
function btnUpgradeAbility0() {
	netUpgradeAbility(me(), 0);
}
function btnUpgradeAbility1() {
	netUpgradeAbility(me(), 0);
}
function btnUpgradeAbility2() {
	netUpgradeAbility(me(), 0);
}
function btnUpgradeAbility3() {
	netUpgradeAbility(me(), 0);
}
function btnUpgradeAbility4() {
	netUpgradeAbility(me(), 0);
}

var BTN_GO_TO_UPGRADE_ABILITIES = 'btnGoToUpgradeAbilities';
function btnGoToUpgradeAbilities() {
	netUiAddActiveQueue(me(), UI_QUEUE.UPGRADE_ABILITIES);
}

function setupHubUi() {
	@async uiAddItem({
		id: null,
		desc: 'Go to smith',
		progress: null,
		button: {
			name: 'Upgrade abilities',
			action: BTN_GO_TO_UPGRADE_ABILITIES,
		},
		queueName: UI_QUEUE.HUB,
		orderName: UI_ORDER.BODY,
		listType: null,
		initVisible: true,
	});
}

function setupHeroesUi(heroesParams) {
	if(TDEF) heroesParams = [THeroParams];

	// select hero
	@async uiAddItem({
		id: null,
		desc: 'SELECT YOUR HERO\n',
		progress: null,
		button: null,
		queueName: UI_QUEUE.SELECT_HERO,
		orderName: UI_ORDER.HEADER,
		listType: null,
		initVisible: true,
	});

	@async uiAddItem({
		id: null,
		desc: '--------',
		progress: {
			initMax: null,
			initCurrent: null,
		},
		button: {
			name: 'Next heroes page',
			action: BTN_UI_NEXT_PAGE,
		},
		queueName: UI_QUEUE.SELECT_HERO,
		orderName: UI_ORDER.LIST_NAV,
		listType: UI_LIST_TYPE.NAV,
		initVisible: false,
	});

	// upgrade abilities
	@async uiAddItem({
		id: null,
		desc: 'UPGRADE ABILITY',
		progress: null,
		button: null,
		queueName: UI_QUEUE.UPGRADE_ABILITIES,
		orderName: UI_ORDER.HEADER,
		listType: null,
		initVisible: true,
	});

	@async uiAddItem({
		id: null,
		desc: '--------',
		progress: null,
		button: {
			name: 'Back',
			action: BTN_UI_BACK,
		},
		queueName: UI_QUEUE.UPGRADE_ABILITIES,
		orderName: UI_ORDER.FOOTER,
		listType: null,
		initVisible: true,
	});

	function processAbility(heroParams, abilityParams) {
		if(TDEF) heroParams = THeroParams;
		if(TDEF) abilityParams = THeroAbilityParams;


		var index = heroParams.abilities.indexOf(abilityParams);

		var passiveText = abilityParams.common.passive ? ' passive' : '';
		var desc = txtBr(heroParams.unitKind) + passiveText + ' ability ' + abilityParams.common.name + ' by level:';

		for (levelIndex in 0...MAX_ABILITY_LEVEL) {
			var level = levelIndex + 1;

			var config = heroAbilityParamsGetConfig(abilityParams.common, level);

			desc = desc + '\n Level ' + level + ': ' + config.description;
			if (config.cooldown != null) {
				desc += ' Cooldown ' + config.cooldown + ' sec.';
			}
			if (config.duration != null) {
				desc += ' Duration ' + config.duration + ' sec.';
			}
			desc += ' Costs ' + config.costAmount + txtBr(config.costRes) + '.';
		}

		var upgradeUiItem = TUIItem;
		upgradeUiItem = {
			id: null,
			desc: desc,
			progress: {
				initMax: MAX_ABILITY_LEVEL,
				initCurrent: 1,
			},
			button: {
				name: 'Upgrade ' + ' ' + CONFIG.ABILITY_UPGRADE_COST + txtBr(CONFIG.ABILITY_UPGRADE_RES),
				action: BTN_UPGRADE_ABILITY_BASE + index,
			},
			queueName: UI_QUEUE.UPGRADE_ABILITIES,
			orderName: UI_ORDER.BODY,
			listType: null,
			initVisible: false,
		};

		abilityParams.common.uiUpgradeItem = upgradeUiItem;

		@async uiAddItem(upgradeUiItem);
	}

	function processAbilityLevel(heroParams, abilityParams, level: Int) {
		if(TDEF) heroParams = THeroParams;
		if(TDEF) abilityParams = THeroAbilityParams;

		var config = heroAbilityParamsGetConfig(abilityParams.common, level);
		var index = heroParams.abilities.indexOf(abilityParams);

		var passiveText = abilityParams.common.passive ? ' passive' : '';
		var desc = txtBr(heroParams.unitKind) + passiveText + ' ability ' + abilityParams.common.name + ' (lvl ' + level + ')\n' + config.description;
		if (config.cooldown != null) {
			desc += ' Cooldown ' + config.cooldown + ' sec.';
		}
		if (config.duration != null) {
			desc += ' Duration ' + config.duration + ' sec.';
		}

		var uiItem = TUIItem;
		uiItem = {
			id: null,
			desc: desc,
			progress: {
				initMax: 1,
				initCurrent: 1,
			},
			button: {
				name: abilityParams.common.name + ' (' + config.costAmount + txtBr(config.costRes) + ')',
				action: BTN_ACTIVATE_ABILITY_BASE + index,
			},
			queueName: UI_QUEUE.MAIN,
			orderName: UI_ORDER.BODY,
			listType: null,
			initVisible: false,
		};

		if (abilityParams.common.uiItemByLevelIndex == null) {
			abilityParams.common.uiItemByLevelIndex = [];
		}

		abilityParams.common.uiItemByLevelIndex.push(uiItem);

		@async uiAddItem(uiItem);
	}

	function handleHero(heroParams) {
		if(TDEF) heroParams = THeroParams;

		heroParams.selectUiItem = {
			id: null,
			desc: heroParams.description,
			progress: null,
			button: {
				name: 'Select ' + txtBr(heroParams.unitKind),
				action: heroParams.selectAction,
			},
			queueName: UI_QUEUE.SELECT_HERO,
			orderName: UI_ORDER.BODY,
			listType: UI_LIST_TYPE.ITEM,
			initVisible: true,
		};

		@async uiAddItem(heroParams.selectUiItem);
	}

	@sync for (heroParams in heroesParams) {
		@async handleHero(heroParams);

		@sync for (abilityParams in heroParams.abilities) {
			@async processAbility(heroParams, abilityParams);

			@sync for (levelIndex in 0...MAX_ABILITY_LEVEL) {
				@async processAbilityLevel(heroParams, abilityParams, levelIndex + 1);
			}
		}
	}
}

// #endregion

// #region Heroes

function _heroBerserkerAbilityWolfsConfig(level: Int) {
	return {
		wolfsCount: intByLevel(level, [2, 3, 4, 5]),
	}
}
var HeroBerserkerAbilityWolfs = THeroAbilityParams;
HeroBerserkerAbilityWolfs = {
	common: {
		name: 'Wolfs master',
		passive: false,
		sound: {
			uiSfx: null,
			unitSfx: UnitSoundWolf,
			volume: 10,
		},
		configByLevel: function _(level: Int) {
			var config = _heroBerserkerAbilityWolfsConfig(level);
			return {
				costRes: Resource.Food,
				costAmount: intByLevel(level, [20, 25, 30, 35]),
				cooldown: 30,
				duration: null,
				description: 'Create ' + config.wolfsCount + ' white wolfs.',
			};
		},
		uiItemByLevelIndex: null,
		uiUpgradeItem: null,
	},
	create: function _(hero, params) {
		var wolfs = TDEF? [TUnit] : [];

		return {
			activate: function activate(level: Int, duration: Float) {
				var config = _heroBerserkerAbilityWolfsConfig(level);

				for (unit in wolfs) {
					unit.owner = null;
					unit.remove();
				}

				if (hero.unit != null && hero.unit.zone != null) {
					wolfs = hero.unit.zone.addUnit(Unit.WhiteWolf, config.wolfsCount, me(), true, null, 10);

					for (unit in wolfs) {
						unit.owner = hero.player;
					}
				}
			},
			upgrade: null,
		}
	}
}

var HeroBerserker = THeroParams;
HeroBerserker = {
	id: 'Berserker',
	unitKind: Unit.Berserker,
	description: "Berserker",

	abilities: [HeroBerserkerAbilityWolfs],

	init: null,

	selectAction: 'btnSelectHeroBerserker',

	selectUiItem: null,
};
HEROES_PARAMS.push(HeroBerserker);
function btnSelectHeroBerserker() {
	netSelectHero(me(), HeroBerserker);
}

var HeroTestBerserker = THeroParams;
HeroTestBerserker = {
	id: 'Berserker2',
	unitKind: Unit.Berserker03,
	description: "Berserker 2",

	abilities: [HeroBerserkerAbilityWolfs],

	init: null,

	selectAction: 'btnSelectHeroTestBerserker',

	selectUiItem: null,
};
HEROES_PARAMS.push(HeroTestBerserker);
function btnSelectHeroTestBerserker() {
	netSelectHero(me(), HeroTestBerserker);
}

// #endregion

// #region Main

function main() {
	// test

	for (plr in USER_PLAYERS) {
		@async plr.addResource(Resource.Stone, 10);
	}

	@async uiAddItem({
		id: null,
		desc: 'Go to smith',
		progress: null,
		button: {
			name: 'Upgrade abilities',
			action: BTN_GO_TO_UPGRADE_ABILITIES,
		},
		queueName: UI_QUEUE.MAIN,
		orderName: UI_ORDER.FOOTER,
		listType: null,
		initVisible: true,
	});
}


// #endregion Main

// #region Dialogs

function dialogIntro() {
	wait(0.5);

	setCamera(ZONES.INIT);
	setZoom(1);

	wait(0.5);

	var unit: Unit;
	if (isHost()) {
		var unit = spawnUnit(ZONES.INIT, FOE_PLAYER, Unit.UndeadGiantDragon, ZONES.INIT.x, ZONES.INIT.y, ZONES.INIT.x + 1, ZONES.INIT.y + 1);
		// var unit = ZONES.INIT.addUnit(Unit.UndeadGiantDragon, 1, FOE_PLAYER).pop();

		// @async unit.hideWeapons();
		// @async unit.orientToPos(unit.x + 1, unit.y + 1);
		@async effectExplosion(ZONES.INIT, unit);
		@async playAnim(unit, 'victory', false, true);
	}

	var options: DialogOptions = {
		name: 'Aghanim',
		font: FontKind.BigTitle,
	};

	sfx(UiSfx.NewFameTitle);

	talk(
		'Welcome to the Northgard Labyrinth!',
		options,
		ZONES.INIT
	);


	talk(
		'It\'s time to test your POWER',
		options,
		ZONES.INIT
	);

	shakeCamera(true);

	talk(
		'Oops, i see you coming... Try to find me!',
		options,
		ZONES.INIT
	);

	if (isHost()) {
		unit.remove();
		effectExplosion(ZONES.INIT, unit);
	}

	// test
	// ZONES.INIT.addUnit(Unit.UndeadGiantDragon, 5, FOE_PLAYER);
}

// #endregion

// #region Init

function init() {
	setupGlobalVars();

	if (state.time == 0) {
		if (isHost()) {
			@async setupHeroesUi(HEROES_PARAMS);
			@async setupHubUi();
			@async main();
			@async uiApplyOrderItems(UI_QUEUE.SELECT_HERO);
		}
	}

	@async setupGlobal();
	if (state.time == 0) {
		@async dialogIntro();
	}
}


// #endregion

// #region Setup

function setupGlobal() {
	noEvent();

	state.removeVictory(Victory.Fame);
	state.removeVictory(Victory.Lore);
	state.removeVictory(Victory.MealSquirrel);
	state.removeVictory(Victory.Military);
	state.removeVictory(Victory.Outsiders);

	addRule(Rule.MushroomsHappy);
	addRule(Rule.WarchiefElimination);
	addRule(Rule.NoMilitPaths);
	addRule(Rule.NoResourceLore);
	addRule(Rule.NoWinter);
	addRule(Rule.NoBuildUI);
	addRule(Rule.NoAllUnitUI);
	addRule(Rule.NoZoneInfo);
	addRule(Rule.HidePlayerList);
	addRule(Rule.NoWarbandCap);
	addRule(Rule.NoBurnBuilding);
	addRule(Rule.RimesteelReplaceIron);


	@sync for (plr in USER_PLAYERS) {
		for (plrZone in state.players) {
			for (zone in plrZone.zones) {
				@async plr.coverZone(zone);
			}
		}

		@async plr.unlockTech(Tech.BearAwake, true);
		@async plr.addBonus({id: ConquestBonus.BResBonus, resId: Resource.Food, isAdvanced: false });
		@async plr.addBonus({id: ConquestBonus.BPopulation, isAdvanced: false});
		@async plr.setResource(Resource.Gemstone, CONFIG.START_LIVES);
	}
}

// #endregion

// Regular update is called every 0.5s
function regularUpdate(elapsed : Float) {
	if (isHost()) {
		@async emitEvent(gameEvents, GlobalEventUpdateData({elapsed: elapsed}));
	}
}

// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder
// space holder