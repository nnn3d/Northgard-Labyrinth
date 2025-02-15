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
		var nextListeners = [];
		for (data in listeners) {
			if (data.callback != eventListener.callback) {
				listeners.push(data);
			}
		}
		eventEmitter.eventsMap.set(eventListener.type, nextListeners);
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

	var nextListeners = [];
	var listeners = eventEmitter.eventsMap.get(eventData.type);

	if (notNull(listeners))  {
		var remove =
		for (data in listeners) {
			FnEventListener = data.callback;
			@async FnEventListener(eventData.payload);

			if (!data.once) {
				nextListeners.push(data);
			}
		}

		eventEmitter.eventsMap.set(eventData.type, nextListeners);
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
	var itemsToHide = TDEF? [TUIItem] : [];
	var itemsToShow = TDEF? [TUIItem] : [];

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

	if (item.initVisible) {
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

// #endregion Net

// #region Effects And Sounds

function effectExplosion(zone: Zone, entity: Entity) {
	var building = zone.createBuilding(Building.MagmaFlow, false, {pos: entity});
	wait(0.01);
	building.destroy();
}

var TUnitSound = {
	unit: TUnitKind,
	sfx: TString,
};
function playSound(sound, zone: Zone, entity: Entity) {
	if(TDEF) sound = TUnitSound;

	if (entity == null) entity = zone;
	zone.addUnit(sound.unit);

}

// #endregion

// #region Global Constants

var UI_QUEUE = {
	INIT: TDEF? TUIQueueNameEnum
		:{queue: 'INIT', pageSize: null},
	SELECT_CHAR: TDEF? TUIQueueNameEnum
		:{queue: 'SELECT_CHAR', pageSize: null},
	SELECT_ROOM: TDEF? TUIQueueNameEnum
		:{queue: 'SELECT_ROOM', pageSize: null},
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

var MAX_ABITLITY_LEVEL = 4;

var CDB = {
	XP_PER_LEVEL: 200,
	POWER_PERCENT_PER_FAME: 1,
}

var CONFIG = {
	START_LIVES: 3,
	DIFFICULTY_MAP: [1, 2.2, 4, 6],
	HERO_REVIVE_COOLDOWN_SEC: 5,
	POWER_PERCENT_PER_LEVEL: 10
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

var USER_HOME_ZONE_MAP = makeStringMap();

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
			USER_HOME_ZONE_MAP.set(plr.name, player.zones.copy()[0]);
		}
		if (plr.isAI && plr.isPlayer() && !plr.team.asPlayer().isAI) {
			ALLY_PLAYER = plr;
		}
		if (plr.isAI && plr.isPlayer() && plr.team.asPlayer().isAI) {
			FOE_PLAYER = plr;
		}
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

	removeEventListener(gameEvents, eventListener);
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

function FnHeroAbilityActivate(): Void {}
function FnHeroAbilityStop(): Void {}
function FnHeroAbilityUpgrade(level: Int): Void {}

var THeroAbility = TDEF? {
	id: TString,
	passive: TBool,

	activate: FnHeroAbilityActivate,
	stop: FnHeroAbilityStop,
	upgrade: FnHeroAbilityUpgrade,
} :null;

var THeroAbilityConfig = TDEF? {
	costRes: TResourceKind,
	costAmount: TInt,
	cooldown: TFloat,
	duration: TFloat,
	desctiption: TString,
} :null;

function FnHeroAbilityConfigByLevel(level: Int) { return THeroAbilityConfig; }
function FnHeroAbilityCreate (hero) {
	hero = THeroPartial;
	return THeroAbility;
}

var THeroAbilityParams = TDEF? {
	id: TString,
	uiItemByLevel: [TUIItem],
	configByLevel: FnHeroAbilityConfigByLevel,
	create: FnHeroAbilityCreate,
} :null;

function NewHeroAbility(abilityParams, hero) {
	if(TDEF) abilityParams = THeroAbilityParams;
	if(TDEF) hero = THeroPartial;
	if(TDEF) return THeroAbility;

	FnHeroAbilityCreate = abilityParams.create;
	return FnHeroAbilityCreate(hero);
}

var THeroParams = TDEF? {
	id: TString,

	unitKind: TUnitKind,
	description: TString,

	ability1: THeroAbilityParams,
	ability2: THeroAbilityParams,
	ability3: THeroAbilityParams,
	abilityUlt: THeroAbilityParams,

	selectAction: TString,
} :null;

var THero = TDEF? {
	params: THeroParams,

	unitKind: TUnitKind,

	player: TPlayer,
	unit: TUnit,

	ability1: THeroAbility,
	ability2: THeroAbility,
	ability3: THeroAbility,
	abilityUlt: THeroAbility,

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
		netGenericNotify(hero.player, 'You died and revive in ' + CONFIG.HERO_REVIVE_COOLDOWN_SEC + ' seconds!', zone);
	} else {
		netGenericNotify(hero.player, 'You died, but has no lives to revive! Wait until your allies clean stage!', zone);
	}

	if (canRevive) {
		hero.player.addResource(Resource.Gemstone, -1);
	}

	// cleanup auto revive from rule WarchiefElimination
	var autoreviveUnit = USER_HOME_ZONE_MAP.get(hero.player.name).getUnit(hero.params.unitKind);
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

	var hero = THero;
	hero = {
		params: heroParams,

		unitKind: heroParams.unitKind,

		player: plr,
		unit: unit,

		ability1: null,
		ability2: null,
		ability3: null,
		abilityUlt: null,

		events: NewEventEmitter(),

		// state
		isAlive: false,
		lastZone: TDEF? TZone : null,
		level: 1,
	}

	hero.ability1 = NewHeroAbility(hero.params.ability1, hero);
	hero.ability2 = NewHeroAbility(hero.params.ability2, hero);
	hero.ability3 = NewHeroAbility(hero.params.ability3, hero);
	hero.abilityUlt = NewHeroAbility(hero.params.abilityUlt, hero);

	onUpdate(function _(elapsed, stop) {
		if (hero.unit != null && hero.unit.zone != null) {
			hero.lastZone = hero.unit.zone;
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

var HERO_ABILITY_NUM = {
	FIRST: 'FIRST',
	SECOND: 'SECOND',
	THIRD: 'THIRD',
	ULT: 'ULT',
}

function heroActivateAbility(hero, abilityNum: String) {
	if(TDEF) hero = THero;

	var ability = THeroAbility;

	switch (abilityNum) {
		case HERO_ABILITY_NUM.FIRST:
			ability = hero.ability1;
		case HERO_ABILITY_NUM.SECOND:
			ability = hero.ability2;
		case HERO_ABILITY_NUM.THIRD:
			ability = hero.ability3;
		case HERO_ABILITY_NUM.ULT:
			ability = hero.abilityUlt;
	}

	if (ability == null) {
		log('Ability with num ' + abilityNum + ' not found');
		return;
	}

	FnHeroAbilityActivate = ability.activate;
	@async FnHeroAbilityActivate();
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

function netActivateAbility(plr: Player, abilityNum: String) {
	invokeHost('_netActivateAbility', _netArgs2(plr, abilityNum));
}
function _netActivateAbility(plr: Player, abilityNum: String) {
	var hero = getHeroByPlayer(plr);
	if (hero != null) {
		heroActivateAbility(hero, abilityNum);
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
	for (heroParams in HEROES_PARAMS) {
		if (heroParams.id == heroId) {
			drakkar(me(), ZONES.INIT, ZONES.INIT_WATER, 0, 0, [heroParams.unitKind]);
			var unit = plr.getUnit(heroParams.unitKind);

			HEROES.push(
				NewHero(heroParams, plr, unit)
			);
			break;
		}
	}
}

// #endregion

// #region Heroes

// var HeroBerserker = THeroParams;
// HeroBerserker = {
// 	id: 'Berserker',
// 	unitKind: Unit.Berserker,
// 	description: ""
// };
// HEROES_PARAMS.push(HeroBerserker);

// #endregion

// #region Main

function main() {
}


// #endregion Main

// #region Dialogs

function dialogIntro() {
	setCamera(ZONES.INIT);
	setZoom(1);

	wait(0.5);

	var unit: Unit;
	if (isHost()) {
		var unit = ZONES.INIT.addUnit(Unit.UndeadGiantDragon, 1, FOE_PLAYER).pop();

		@split[
			unit.hideWeapons(),
			unit.orientToPos(unit.x + 1, unit.y + 1),
			effectExplosion(ZONES.INIT, unit),
			playAnim(unit, 'victory', false, true),
		];
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
	ZONES.INIT.addUnit(Unit.UndeadGiantDragon, 5, FOE_PLAYER);
}

// #endregion

// #region Init

function init() {
	setupGlobalVars();

	if (state.time == 0) {
		if (isHost()) {
			@async main();
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
		@async plr.setResource(Resource.Gemstone, CONFIG.START_LIVES);
	}
}

// #endregion

// Regular update is called every 0.5s
function regularUpdate(elapsed : Float) {
	if (isHost()) {
		emitEvent(gameEvents, GlobalEventUpdateData({elapsed: elapsed}));
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