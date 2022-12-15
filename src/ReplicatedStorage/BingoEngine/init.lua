--[[

    Commit: 03/10/22 @14:21 - Added the methods "GetService", "GetComponent", and "SetupGlobalComponents"
    Commit: 08/10/22 @12:15 - Added type: Service, and Controller. More syntax sugar for methods with backwards compatibility.
    Services and Controllers are now instantiated with a function call which returns a Service or Controller object.


    BASIC USAGE:
    Engine.Start(Folder, "Service%"):andThen(function()
        -- Engine has successfully loaded.
        warn("BingoEngine has been loaded.")
    end):catch(warn);

]]--
local MODULE_ALREADY_EXISTS = "%s already exists."
local MODULE_DOES_NOT_EXIST = "%s does not exist."

local Engine = {
	Network = require(script.Network),
	StateMachine = require(script.StateMachine),
	Utils = {
		EnumList = require(script.Utils.EnumList),
		Maths = require(script.Utils.Maths),
		Promise = require(script.Utils.Promise),
		Roact = require(script.Utils.Roact),
		Rodux = require(script.Utils.Rodux),
		Signal = require(script.Utils.Signal),
		Trove = require(script.Utils.Trove),
		Spring = require(script.Utils.Spring),
    }
}

local Promise = Engine.Utils.Promise

local services = {}

function Engine.Start(parent: Instance, match: string)
    --@ param {Instance} parent: The container of the modules
    --@ param {String} match: Only requirinig modules with a specific format
        --@ default: Will just require all modules within the container.

    --@ return {Promise}
    return Promise.new(function(resolve, reject)
        local providers = {}
	
        -- Setup the services and controllers
        for _, module: ModuleScript in parent:GetDescendants() do
            if (module:IsA("ModuleScript") and if (match) then module.Name:match(match) else true) then
                local provider = require(module)
                
                if (services[module.Name]) then
                    reject(MODULE_ALREADY_EXISTS:format(module.Name))
                end

                if (provider.Disabled) then
                    continue
                end
                
                services[module.Name] = provider
                
                if (typeof(provider.OnInit) == "function") then
                    Promise.promisify(provider.OnInit, provider)	
                end

                -- Isolate the ones that have an "OnStart method" which will invoke when all the modules have been loaded
                if (typeof(provider.OnStart) == "function") then
                    table.insert(providers, provider)
                end
            end
        end

        for _, provider in providers do
            Promise.promisify(provider.OnStart, provider, services)
        end
        
        resolve(services)
    end)
end

function Engine.GetService(name: string)
    return Promise.new(function(resolve, reject)
        local service = services[name]
        if (service) then
            resolve(service)
        else
            reject(MODULE_DOES_NOT_EXIST:format(name))
        end
    end)
	
end

-- Syntactic sugar
function Engine.GetController(name: string)
	return Engine.GetService(name)
end

return Engine