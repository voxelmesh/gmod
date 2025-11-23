AnimFreeze = AnimFreeze or {}
AnimFreeze.frozenEntities = AnimFreeze.frozenEntities or {}

local function resetBoneManipulations(ent)
    for i = 0, ent:GetBoneCount() - 1 do
        ent:ManipulateBonePosition(i, Vector(0, 0, 0))
        ent:ManipulateBoneAngles(i, Angle(0, 0, 0))
    end
end

local function freezeEntity(ent)
    ent:SetSequence(0)
    ent:SetPlaybackRate(0)
    ent:SetCycle(0)
    
    for i = 0, ent:GetNumPoseParameters() - 1 do
        ent:SetPoseParameter(i, 0)
    end
end

local function shouldFreeze(ent)
    return AnimFreeze.frozenEntities[ent] == true
end

local function playerSpawnReset(ply)
    if not shouldFreeze(ply) then return end
    timer.Simple(0, function()
        if IsValid(ply) then
            resetBoneManipulations(ply)
            freezeEntity(ply)
        end
    end)
end

local function playerModelReset(ply)
    if not shouldFreeze(ply) then return end
    timer.Simple(0, function()
        if IsValid(ply) then
            resetBoneManipulations(ply)
            freezeEntity(ply)
        end
    end)
end

local function playerCalcActivity(ply, vel)
    if not shouldFreeze(ply) then return end
    freezeEntity(ply)
    return ACT_INVALID, -1
end

local function playerUpdateAnim(ply, vel, maxSeqGroundSpeed)
    if not shouldFreeze(ply) then return end
    freezeEntity(ply)
    return true
end

local function playerSetupMove(ply, mv, cmd)
    if not shouldFreeze(ply) then return end
    for i = 0, ply:GetNumPoseParameters() - 1 do
        ply:SetPoseParameter(i, 0)
    end
end

local function playerDoAnimEvent(ply, event, data)
    if not shouldFreeze(ply) then return end
    return ACT_INVALID
end

local function npcEntityCreated(ent)
    if not shouldFreeze(ent) then return end
    timer.Simple(0, function()
        if IsValid(ent) and ent:IsNPC() then
            resetBoneManipulations(ent)
            freezeEntity(ent)
        end
    end)
end

local function npcThink()
    for ent, _ in pairs(AnimFreeze.frozenEntities) do
        if IsValid(ent) and ent:IsNPC() then
            freezeEntity(ent)
        end
    end
end

local function cleanupInvalidEntities()
    for ent, _ in pairs(AnimFreeze.frozenEntities) do
        if not IsValid(ent) then
            AnimFreeze.frozenEntities[ent] = nil
        end
    end
end

function AnimFreeze.freeze(ent)
    if not IsValid(ent) then
        print("[AnimFreeze] invalid entity")
        return false
    end

    if AnimFreeze.frozenEntities[ent] then
        return false -- Already frozen
    end

    AnimFreeze.frozenEntities[ent] = true
    resetBoneManipulations(ent)
    freezeEntity(ent)

    local entType = ent:IsPlayer() and "Player" or (ent:IsNPC() and "NPC" or "Entity")
    return true
end

function AnimFreeze.unfreeze(ent)
    if not IsValid(ent) then
        print("[AnimFreeze] invalid entity")
        return false
    end

    if not AnimFreeze.frozenEntities[ent] then
        return false -- Not frozen
    end

    AnimFreeze.frozenEntities[ent] = nil
    resetBoneManipulations(ent)
    ent:SetPlaybackRate(1)

    local entType = ent:IsPlayer() and "Player" or (ent:IsNPC() and "NPC" or "Entity")
    return true
end

function AnimFreeze.toggle(ent)
    if not IsValid(ent) then
        print("[AnimFreeze] invalid entity")
        return
    end

    if AnimFreeze.frozenEntities[ent] then
        AnimFreeze.unfreeze(ent)
    else
        AnimFreeze.freeze(ent)
    end
end

function AnimFreeze.isFrozen(ent)
    return AnimFreeze.frozenEntities[ent] == true
end

function AnimFreeze.unfreezeAll()
    local count = 0
    for ent, _ in pairs(AnimFreeze.frozenEntities) do
        if IsValid(ent) then
            resetBoneManipulations(ent)
            ent:SetPlaybackRate(1)
            count = count + 1
        end
    end
    AnimFreeze.frozenEntities = {}
end

function AnimFreeze.getFrozenEntities()
    local frozen = {}
    for ent, _ in pairs(AnimFreeze.frozenEntities) do
        if IsValid(ent) then
            table.insert(frozen, ent)
        end
    end
    return frozen
end

hook.Add("PlayerSpawn", "AnimFreeze_PlayerSpawn", playerSpawnReset)
hook.Add("PlayerSetModel", "AnimFreeze_PlayerModel", playerModelReset)
hook.Add("CalcMainActivity", "AnimFreeze_CalcActivity", playerCalcActivity)
hook.Add("UpdateAnimation", "AnimFreeze_UpdateAnim", playerUpdateAnim)
hook.Add("SetupMove", "AnimFreeze_SetupMove", playerSetupMove)
hook.Add("DoAnimationEvent", "AnimFreeze_DoAnimEvent", playerDoAnimEvent)
hook.Add("OnEntityCreated", "AnimFreeze_NPCCreated", npcEntityCreated)
hook.Add("Think", "AnimFreeze_NPCThink", npcThink)
hook.Add("Think", "AnimFreeze_Cleanup", cleanupInvalidEntities)
