local addOnName, AddOn = ...
Bot = Bot or {}

Bot.Warrior = {}

local _ = {}

local function retrieveHighestRankSpellID(spellID)
  local name = GetSpellInfo(spellID)
  local highestRankSpellID = select(7, GetSpellInfo(name))
  return highestRankSpellID
end

local HEROIC_STRIKE_RANK_1 = 78
local BATTLE_SHOUT_RANK_1 = 6673
local REND_RANK_1 = 772
local CHARGE_RANK_1 = 100
local VICTORY_RUSH_RANK_1 = 34428

local HEROIC_STRIKE = retrieveHighestRankSpellID(HEROIC_STRIKE_RANK_1)
local BATTLE_SHOUT = retrieveHighestRankSpellID(BATTLE_SHOUT_RANK_1)
local REND = retrieveHighestRankSpellID(REND_RANK_1)
local CHARGE = retrieveHighestRankSpellID(CHARGE_RANK_1)
local VICTORY_RUSH = retrieveHighestRankSpellID(VICTORY_RUSH_RANK_1)

local HEROIC_STRIKE_NAME = GetSpellInfo(HEROIC_STRIKE)
local REND_NAME = GetSpellInfo(REND)

function Bot.Warrior.castSpell()
  if _.areConditionsMetToCastVictoryRush() then
    CastSpellByID(VICTORY_RUSH)
  elseif _G.RecommendedSpellCaster then
    RecommendedSpellCaster.castRecommendedSpell()
  end
end

function _.areConditionsMetToCastVictoryRush()
  local characterHealthInPercent = UnitHealth('player') / UnitHealthMax('player')
  return (
    SpellCasting.canBeCasted(VICTORY_RUSH) and
    characterHealthInPercent <= 0.8
  )
end

function _.retrievePlayerAuraBySpellID(spellID)
  return Core.findAuraByID(spellID, 'player')
end

function _.areConditionsMetToCastCharge()
  return SpellCasting.canBeCasted(CHARGE) and
    IsSpellInRange(CHARGE, 'target')
end

function _.areConditionsMetToCastBattleShout()
  local hasBattleShoutBuff = Boolean.toBoolean(_.retrievePlayerAuraBySpellID(BATTLE_SHOUT))
  return (
    not hasBattleShoutBuff and SpellCasting.canBeCasted(BATTLE_SHOUT)
  )
end

function _.areConditionsMetToCastRend()
  return (
    SpellCasting.canBeCasted(REND) and
      IsSpellInRange(REND_NAME, 'target') and
      not Core.findAuraByID(REND, 'target', 'HARMFUL')
  )
end

function _.areConditionsMetToCastHeroicStrike()
  local lowDamage = UnitDamage('player')
  local targetHealth = UnitHealth('target')
  return (
    not IsCurrentSpell(HEROIC_STRIKE) and
      SpellCasting.canBeCasted(HEROIC_STRIKE) and
      IsSpellInRange(HEROIC_STRIKE_NAME, 'target') and
      targetHealth > lowDamage
  )
end
