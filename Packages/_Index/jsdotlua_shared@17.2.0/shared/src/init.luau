--!strict
--[[
	* Copyright (c) Roblox Corporation. All rights reserved.
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]

-- ROBLOX deviation: Promote `shared` to an actual unpublished package with a
-- real interface instead of just a bag of loose source code
local LuauPolyfill = require(script.Parent:WaitForChild('luau-polyfill'))
type Object = LuauPolyfill.Object

local ReactTypes = require(script:WaitForChild('ReactTypes'))
local flowtypes = require(script:WaitForChild('flowtypes.roblox'))
local ReactElementType = require(script:WaitForChild('ReactElementType'))
local ReactFiberHostConfig = require(script:WaitForChild('ReactFiberHostConfig'))
local ReactSharedInternals = require(script:WaitForChild('ReactSharedInternals'))
local ErrorHandling = require(script:WaitForChild('ErrorHandling.roblox'))
-- Re-export all top-level public types

export type ReactEmpty = ReactTypes.ReactEmpty
export type ReactFragment = ReactTypes.ReactFragment
export type ReactNodeList = ReactTypes.ReactNodeList
export type ReactProviderType<T> = ReactTypes.ReactProviderType<T>
export type ReactConsumer<T> = ReactTypes.ReactConsumer<T>
export type ReactProvider<T> = ReactTypes.ReactProvider<T>
export type ReactContext<T> = ReactTypes.ReactContext<T>
export type ReactPortal = ReactTypes.ReactPortal
export type RefObject = ReactTypes.RefObject
export type EventPriority = ReactTypes.EventPriority
export type ReactFundamentalComponentInstance<C, H> =
	ReactTypes.ReactFundamentalComponentInstance<C, H>
export type ReactFundamentalImpl<C, H> = ReactTypes.ReactFundamentalImpl<C, H>
export type ReactFundamentalComponent<C, H> = ReactTypes.ReactFundamentalComponent<C, H>
export type ReactScope = ReactTypes.ReactScope
export type ReactScopeQuery = ReactTypes.ReactScopeQuery
export type ReactScopeInstance = ReactTypes.ReactScopeInstance
-- ROBLOX deviation START: Re-export bindings types
export type ReactBinding<T> = ReactTypes.ReactBinding<T>
export type ReactBindingUpdater<T> = ReactTypes.ReactBindingUpdater<T>
-- ROBLOX deviation END
export type MutableSourceVersion = ReactTypes.MutableSourceVersion
export type MutableSourceGetSnapshotFn<Source, Snapshot> =
	ReactTypes.MutableSourceGetSnapshotFn<Source, Snapshot>
export type MutableSourceSubscribeFn<Source, Snapshot> = ReactTypes.MutableSourceSubscribeFn<
	Source,
	Snapshot
>
export type MutableSourceGetVersionFn = ReactTypes.MutableSourceGetVersionFn
export type MutableSource<Source> = ReactTypes.MutableSource<Source>
export type Wakeable = ReactTypes.Wakeable
export type Thenable<R> = ReactTypes.Thenable<R>
export type Source = ReactElementType.Source
export type ReactElement<P = Object, T = any> = ReactElementType.ReactElement<P, T>
export type OpaqueIDType = ReactFiberHostConfig.OpaqueIDType
export type Dispatcher = ReactSharedInternals.Dispatcher

-- re-export flowtypes from here. I wonder if this should be a separate 'package'?
export type React_Ref<ElementType> = flowtypes.React_Ref<ElementType>
export type React_Context<T> = flowtypes.React_Context<T>
export type React_AbstractComponent<Config, Instance> = flowtypes.React_AbstractComponent<
	Config,
	Instance
>
export type React_ForwardRefComponent<Config, Instance> =
	flowtypes.React_ForwardRefComponent<Config, Instance>
export type React_MemoComponent<Config, T> = flowtypes.React_MemoComponent<Config, T>
export type React_ComponentType<Config> = flowtypes.React_ComponentType<Config>
export type React_PureComponent<Props, State = nil> = flowtypes.React_PureComponent<
	Props,
	State
>
export type React_Component<Props, State> = flowtypes.React_Component<Props, State>
export type React_ElementProps<ElementType> = flowtypes.React_ElementProps<ElementType>
export type React_StatelessFunctionalComponent<Props> =
	flowtypes.React_StatelessFunctionalComponent<Props>
export type React_Node = flowtypes.React_Node
export type React_Element<ElementType> = flowtypes.React_Element<ElementType>
export type React_ElementType = flowtypes.React_ElementType
export type React_ElementConfig<C> = flowtypes.React_ElementConfig<C>
export type React_ElementRef<C> = flowtypes.React_ElementRef<C>
export type React_Portal = flowtypes.React_Portal
export type React_Key = flowtypes.React_Key

return {
	checkPropTypes = require(script:WaitForChild('checkPropTypes')),
	console = require(script:WaitForChild('console')),
	ConsolePatchingDev = require(script:WaitForChild('ConsolePatchingDev.roblox')),
	consoleWithStackDev = require(script:WaitForChild('consoleWithStackDev')),
	enqueueTask = require(script:WaitForChild('enqueueTask.roblox')),
	ExecutionEnvironment = require(script:WaitForChild('ExecutionEnvironment')),
	formatProdErrorMessage = require(script:WaitForChild('formatProdErrorMessage')),
	getComponentName = require(script:WaitForChild('getComponentName')),
	invariant = require(script:WaitForChild('invariant')),
	invokeGuardedCallbackImpl = require(script:WaitForChild('invokeGuardedCallbackImpl')),
	isValidElementType = require(script:WaitForChild('isValidElementType')),
	objectIs = require(script:WaitForChild('objectIs')),
	ReactComponentStackFrame = require(script:WaitForChild('ReactComponentStackFrame')),
	ReactElementType = require(script:WaitForChild('ReactElementType')),
	ReactErrorUtils = require(script:WaitForChild('ReactErrorUtils')),
	ReactFeatureFlags = require(script:WaitForChild('ReactFeatureFlags')),
	ReactInstanceMap = require(script:WaitForChild('ReactInstanceMap')),
	-- ROBLOX deviation: Instead of re-exporting from here, Shared actually owns
	-- these files itself
	ReactSharedInternals = ReactSharedInternals,
	-- ROBLOX deviation: Instead of extracting these out of the reconciler and
	-- then re-injecting the host config _into_ the reconciler, export these
	-- from shared for easier reuse
	ReactFiberHostConfig = ReactFiberHostConfig,

	ReactSymbols = require(script:WaitForChild('ReactSymbols')),
	ReactVersion = require(script:WaitForChild('ReactVersion')),
	shallowEqual = require(script:WaitForChild('shallowEqual')),
	UninitializedState = require(script:WaitForChild('UninitializedState.roblox')),
	ReactTypes = ReactTypes,

	-- ROBLOX DEVIATION: export error-stack-preserving utilities for use in
	-- scheduler and reconciler, and parsing function for use in public API
	describeError = ErrorHandling.describeError,
	errorToString = ErrorHandling.errorToString,
	parseReactError = ErrorHandling.parseReactError,

	-- ROBLOX DEVIATION: export Symbol and Type from Shared
	Symbol = require(script:WaitForChild('Symbol.roblox')),
	Type = require(script:WaitForChild('Type.roblox')),

	-- ROBLOX DEVIATION: export propmarkers from Shared
	Change = require(script:WaitForChild('PropMarkers'):WaitForChild('Change')),
	Event = require(script:WaitForChild('PropMarkers'):WaitForChild('Event')),
	Tag = require(script:WaitForChild('PropMarkers'):WaitForChild('Tag')),
}
