#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <colors>
#include <sdktools_functions>

#pragma semicolon 1

new Handle:RestartTimers = INVALID_HANDLE;

#define PLUGIN_NAME 			"Só Na Net"
#define PLUGIN_AUTHOR 			"zlVal"
#define PLUGIN_DESCRIPTION		"Plugin"
#define PLUGIN_VERSION 			"1.0.0"
#define PLUGIN_TAG 				"{darkred}[só na net]{green}"
#define WARMUP 1
#define KNIFE_ROUND 2
#define MATCH 3
int CurrentRound;
int WinningTeam;
int KRWinner;
int team_t;
int team_ct;
bool forceready;
bool UnpauseLock;
bool readyT;
bool readyCT;
bool TacticUnpauseCT;
bool TacticUnpauseT;
bool mix;
bool escolha;

public Plugin myinfo =
{
    name				=    PLUGIN_NAME,
    author				=    PLUGIN_AUTHOR,
    description			=    PLUGIN_DESCRIPTION,
    version				=    PLUGIN_VERSION,
    url					= 	   ""
};

public void OnPluginStart()
{
  RegConsoleCmd("sm_mirage", Command_mirage, "de_mirage");
  RegConsoleCmd("sm_cache", Command_cache, "de_cache");
  RegConsoleCmd("sm_dust2", Command_dust2, "de_dust2");
  RegConsoleCmd("sm_train", Command_train, "de_train");
  RegConsoleCmd("sm_inferno", Command_inferno, "de_inferno");
  RegConsoleCmd("sm_overpass", Command_overpass, "de_overpass");
  RegConsoleCmd("sm_cbble", Command_cbble, "de_cbble");
  RegConsoleCmd("sm_nuke", Command_nuke, "de_nuke");
  RegAdminCmd("smpadmin_kniferound_random", KnifeRoundRandom, ADMFLAG_ROOT, "Random captains knife round when no admin is online");
  RegAdminCmd("smpadmin_match", Ladder5on5SMP, ADMFLAG_ROOT, "Load 5on5 Config");
  RegAdminCmd("sm_forceunpause", ForceUnPauseSMP, ADMFLAG_GENERIC, "Force unpause (Admin only)");
  RegAdminCmd("sm_forceready", ForceReady, ADMFLAG_GENERIC, "Force Match");
  RegConsoleCmd("sm_pause", TacticPauseSMP, "Team tactic pause");
  RegConsoleCmd("sm_unpause", TacticUnpauseSMP, "Team tactic unpause");
  RegConsoleCmd("sm_ready", ReadySMP, "Set yourself as Ready.");
  RegConsoleCmd("sm_unready", UnreadySMP, "Set yourself as Unready.");
  RegAdminCmd("sm_sonanet", Command_sonanet, ADMFLAG_GENERIC, "Só na net");
  RegAdminCmd("sm_warmup", WarmupSMP, ADMFLAG_GENERIC, "Warmup");
  RegConsoleCmd("sm_mix", Command_mix, "Mix só na net");
  RegConsoleCmd("sm_stay", StaySMP, "No team change (after knife round)");
  RegConsoleCmd("sm_switch", SwitchSMP, "Change teams (after knife round)");
  HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
}

public Action ForceReady(int client, int args)
{
  if(!escolha)
  {
    CPrintToChat(client, "%s Não foi selecionado o tipo de jogo.", PLUGIN_TAG);
    return Plugin_Handled;
  }
  else if(mix)
  {
    CPrintToChatAll("%s O jogo irá começar dentro de 5 segundos.", PLUGIN_TAG);
    forceready = true;
    CreateTimer(5.0, KnifeRoundRandomTimer);
    return Plugin_Handled;
  }
  else if(!mix)
  {
    CPrintToChatAll("%s Match will start in 5 seconds.", PLUGIN_TAG);
    forceready = true;
    CreateTimer(5.0, KnifeRoundRandomTimer);
    return Plugin_Handled;
  }
}

public bool IsTeamReady(client)
{
	if (GetClientTeam(client) == CS_TEAM_CT)
  {
    return readyCT;
  }
  else
  {
    return readyT;
  }
}

public bool ClientTeamValid(client)
{
	int ClientTeam = GetClientTeam(client);
	if (ClientTeam != CS_TEAM_CT && ClientTeam != CS_TEAM_T)
	{
		return false;
	}
	return true;
}

public Action KnifeRoundRandomTimer(Handle timer)
{
	ServerCommand("smpadmin_kniferound_random");
}

public Action ReadySMP(client, args)
{
  if(!escolha)
  {
    CPrintToChat(client, "%s Não foi selecionado o tipo de jogo.", PLUGIN_TAG);
  }
  else if(mix)
  {
    if (CurrentRound == WARMUP && forceready == false)
  	{
  		if (!IsTeamReady(client))
  		{
  			if(GetClientTeam(client) == CS_TEAM_CT && readyT)
        {
          readyCT = true;
          CPrintToChatAll("%s A equipa Contra Terrorista está pronta. O jogo irá começar dentro de 5 segundos.", PLUGIN_TAG);
          CreateTimer(5.0, KnifeRoundRandomTimer);
        }
        else if(GetClientTeam(client) == CS_TEAM_CT && !readyT)
        {
          readyCT = true;
          CPrintToChatAll("%s A equipa Contra Terrorista está pronta. O jogo começa quando a equipa Terrorista estiver pronta.", PLUGIN_TAG);
        }
        else if(GetClientTeam(client) == CS_TEAM_T && readyCT)
        {
          readyT = true;
          CPrintToChatAll("%s A equipa Terrorista está pronta. O jogo irá começar dentro de 5 segundos.", PLUGIN_TAG);
          CreateTimer(5.0, KnifeRoundRandomTimer);
        }
        else
        {
          readyT = true;
          CPrintToChatAll("%s A equipa Terrorista está pronta. O jogo começa quando a equipa Contra Terrorista estiver pronta.", PLUGIN_TAG);
        }
  		}
      else
      {
        CPrintToChat(client, "%s A tua equipa já está pronta.", PLUGIN_TAG);
      }
  	}
  	else if (CurrentRound != WARMUP)
  	{
  		return Plugin_Handled;
  	}
  }
  else if(!mix)
  {
    if (CurrentRound == WARMUP && forceready == false)
  	{
      if (!IsTeamReady(client))
  		{
  			if(GetClientTeam(client) == CS_TEAM_CT && readyT)
        {
          readyCT = true;
          CPrintToChatAll("%s Counter Terrorist Team is ready. Match will begin shortly.", PLUGIN_TAG);
          CreateTimer(5.0, KnifeRoundRandomTimer);
        }
        else if(GetClientTeam(client) == CS_TEAM_CT && !readyT)
        {
          readyCT = true;
          CPrintToChatAll("%s Counter Terrorist Team is ready. Waiting for Terrorist Team.", PLUGIN_TAG);
        }
        else if(GetClientTeam(client) == CS_TEAM_T && readyCT)
        {
          readyT = true;
          CPrintToChatAll("%s Terrorist Team is ready. Match will begin shortly.", PLUGIN_TAG);
          CreateTimer(5.0, KnifeRoundRandomTimer);
        }
        else
        {
          readyT = true;
          CPrintToChatAll("%s Terrorist Team is ready. Waiting for Counter Terrorist Team.", PLUGIN_TAG);
        }
  		}
      else
      {
        CPrintToChat(client, "%s Your Team is already ready.", PLUGIN_TAG);
      }
  	}
  	else if (CurrentRound != WARMUP)
  	{
  		return Plugin_Handled;
  	}
  }
	return Plugin_Handled;
}

public Action UnreadySMP(client, args)
{
  if(!escolha)
  {
    CPrintToChat(client, "%s Não foi selecionado o tipo de jogo.", PLUGIN_TAG);
  }
  else if(mix)
  {
  	if (CurrentRound == WARMUP)
  	{
      if(IsTeamReady(client))
      {
        if(GetClientTeam(client) == CS_TEAM_CT && !readyT)
        {
          readyCT = false;
          CPrintToChatAll("%s A equipa Contra Terrorista não está pronta.", PLUGIN_TAG);
        }
        else if(GetClientTeam(client) == CS_TEAM_T && !readyT)
        {
          readyT = false;
          CPrintToChatAll("%s A equipa Terrorista não está pronta.", PLUGIN_TAG);
        }
      }
      else
      {
        CPrintToChat(client, "%s A tua equipa não está pronta.");
      }
  	}
  	else if (CurrentRound != WARMUP)
  	{
  		return Plugin_Handled;
  	}
  	return Plugin_Handled;
  }
  else if(!mix)
  {
    if (CurrentRound == WARMUP)
  	{
      if(IsTeamReady(client))
      {
        if(GetClientTeam(client) == CS_TEAM_CT && !readyT)
        {
          readyCT = false;
          CPrintToChatAll("%s Counter Terrorist Team is unready.", PLUGIN_TAG);
        }
        else if(GetClientTeam(client) == CS_TEAM_T && !readyT)
        {
          readyT = false;
          CPrintToChatAll("%s Terrorist Team is unready.", PLUGIN_TAG);
        }
      }
      else
      {
        CPrintToChat(client, "%s Your Team is already unready.");
      }
  	}
  	else if (CurrentRound != WARMUP)
  	{
  		return Plugin_Handled;
  	}
  	return Plugin_Handled;
  }
}

bool StayUsed;
public bool CanUseStay()
{
	if (StayUsed)
	{
		return false;
	}
	return true;
}

bool SwitchUsed;
public bool CanUseSwitch()
{
	if (SwitchUsed)
	{
		return false;
	}
	return true;
}

public void ResetValues()
{
	StayUsed = false;
	SwitchUsed = false;
}

stock bool IsPaused()
{
	return GameRules_GetProp("m_bMatchWaitingForResume") != 0;
}

public Action ForceUnPauseSMP(client, args)
{
	if (!IsPaused())
	{
		return Plugin_Handled;
	}
	ServerCommand("mp_unpause_match");
	return Plugin_Handled;
}

public Action StartMatch(Handle timer)
{
	ServerCommand("smpadmin_match");
}

public Action StaySMP(int client, int args)
{
  if(!escolha)
  {
    CPrintToChat(client, "%s Não foi selecionado o tipo de jogo.", PLUGIN_TAG);
    return Plugin_Handled;
  }
  else if(mix)
  {
    if (WinningTeam == CS_TEAM_T)
  	{
  		if (GetClientTeam(client) == CS_TEAM_T)
  		{
  				if (CanUseStay())
  			{
  					CPrintToChatAll("%s A equipa Terrorista decidiu não trocar de equipa!", PLUGIN_TAG);
  					ForceUnPauseSMP(client, args);
  					StayUsed = true;
  					CreateTimer(2.0, StartMatch);
  					return Plugin_Handled;
  			}
  		}
  	}

  	else if (WinningTeam == CS_TEAM_CT)
  	{
  		if (GetClientTeam(client) == CS_TEAM_CT)
  		{
  				if (CanUseStay())
  			{
  					CPrintToChatAll("%s A equipa Contra Terrorista decidiu não trocar de equipa!", PLUGIN_TAG);
  					ForceUnPauseSMP(client, args);
  					StayUsed = true;
  					CreateTimer(2.0, StartMatch);
  					return Plugin_Handled;
  			}
  		}
  	}
  }
  else if(!mix)
  {
    if (WinningTeam == CS_TEAM_T)
  	{
  		if (GetClientTeam(client) == CS_TEAM_T)
  		{
  				if (CanUseStay())
  			{
  					CPrintToChatAll("%s Terrorist Team decided to stay!", PLUGIN_TAG);
  					ForceUnPauseSMP(client, args);
  					StayUsed = true;
  					CreateTimer(2.0, StartMatch);
  					return Plugin_Handled;
  			}
  		}
  	}

  	else if (WinningTeam == CS_TEAM_CT)
  	{
  		if (GetClientTeam(client) == CS_TEAM_CT)
  		{
  				if (CanUseStay())
  			{
  					CPrintToChatAll("%s Counter Terrorist Team decided to stay!", PLUGIN_TAG);
  					ForceUnPauseSMP(client, args);
  					StayUsed = true;
  					CreateTimer(2.0, StartMatch);
  					return Plugin_Handled;
  			}
  		}
  	}
  }

	CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
	return Plugin_Handled;
}

public Action Command_mix(int client, int args)
{
  if(!escolha)
  {
    CPrintToChatAll("%s {orange}Foi selecionado o modo Mix!{green}", PLUGIN_TAG);
    escolha = true;
    mix = true;
  }
  else
  {
    if(!mix)
    {
      CPrintToChatAll("%s {orange}Foi selecionado o modo Mix!{green}", PLUGIN_TAG);
      escolha = true;
      mix = true;
    }
  }
}

public Action SwitchSMP(int client, int args)
{
  if(!escolha)
  {
    CPrintToChat(client, "%s Não foi selecionado o tipo de jogo.", PLUGIN_TAG);
    return Plugin_Handled;
  }
  else if(mix)
  {
    if (WinningTeam == CS_TEAM_T)
  	{
  		if (GetClientTeam(client) == CS_TEAM_T)
  		{
  				if (CanUseSwitch())
  			{
  					CPrintToChatAll("%s A equipa Terrorista decidiu trocar de equipas!", PLUGIN_TAG);
  					ServerCommand("mp_swapteams");
  					ForceUnPauseSMP(client, args);
  					SwitchUsed = true;
  					CreateTimer(2.0, StartMatch);
  					return Plugin_Handled;
  			}
  		}
  	}

  	else if (WinningTeam == CS_TEAM_CT)
  	{
  		if (GetClientTeam(client) == CS_TEAM_CT)
  		{
  				if (CanUseSwitch())
  			{
  					CPrintToChatAll("%s A equipa Contra Terrorista decidiu trocar de equipas!", PLUGIN_TAG);
  					ServerCommand("mp_swapteams");
  					ForceUnPauseSMP(client, args);
  					SwitchUsed = true;
  					CreateTimer(2.0, StartMatch);
  					return Plugin_Handled;
  			}
  		}
  	}
  }
  else if(!mix)
  {
    if (WinningTeam == CS_TEAM_T)
  	{
  		if (GetClientTeam(client) == CS_TEAM_T)
  		{
  				if (CanUseSwitch())
  			{
  					CPrintToChatAll("%s Terrorist Team decided to switch teams!", PLUGIN_TAG);
  					ServerCommand("mp_swapteams");
  					ForceUnPauseSMP(client, args);
  					SwitchUsed = true;
  					CreateTimer(2.0, StartMatch);
  					return Plugin_Handled;
  			}
  		}
  	}

  	else if (WinningTeam == CS_TEAM_CT)
  	{
  		if (GetClientTeam(client) == CS_TEAM_CT)
  		{
  				if (CanUseSwitch())
  			{
  					CPrintToChatAll("%s Counter Terrorist Team decided to switch teams!", PLUGIN_TAG);
  					ServerCommand("mp_swapteams");
  					ForceUnPauseSMP(client, args);
  					SwitchUsed = true;
  					CreateTimer(2.0, StartMatch);
  					return Plugin_Handled;
  			}
  		}
  	}
  }

	CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
	return Plugin_Handled;
}

stock bool IsClientValid(int client)
{
	if (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
		return true;
	return false;
}

GetAlivePlayersCount(iTeam)
{
	int iCount, i; iCount = 0;

	for (i = 1; i <= MaxClients; i++)
	if (IsClientValid(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam)
		iCount++;

	return iCount;
}

public Action WinningKnifeRoundTeam()
{
	KRWinner = CS_TEAM_NONE;
	team_t = GetAlivePlayersCount(CS_TEAM_T);
	team_ct = GetAlivePlayersCount(CS_TEAM_CT);
	if (team_t > team_ct)
	{
		KRWinner = CS_TEAM_T;
	}
	else if (team_ct > team_t)
	{
		KRWinner = CS_TEAM_CT;
	}
	return Plugin_Handled;
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    if(mix)
    {
      if (CurrentRound == KNIFE_ROUND)
    	{
    		WinningKnifeRoundTeam();
    		WinningTeam = KRWinner;
    		ServerCommand("mp_pause_match");
    		if (WinningTeam == CS_TEAM_T)
    		{
    			CPrintToChatAll("%s A equipa Terrorista ganhou a ronda! {orange}!stay{green} ou {orange}!switch{green}", PLUGIN_TAG);
    		}
    		else if (WinningTeam == CS_TEAM_CT)
    		{
    			CPrintToChatAll("%s A equipa Contra Terrorista ganhou a ronda! {orange}!stay{green} ou {orange}!switch{green}", PLUGIN_TAG);
    		}
    		return Plugin_Handled;
    	}
    }
    else if(!mix)
    {
      if (CurrentRound == KNIFE_ROUND)
    	{
    		WinningKnifeRoundTeam();
    		WinningTeam = KRWinner;
    		ServerCommand("mp_pause_match");
    		if (WinningTeam == CS_TEAM_T)
    		{
    			CPrintToChatAll("%s Terrorist Team wins the round! {orange}!stay{green} or {orange}!switch{green}", PLUGIN_TAG);
    		}
    		else if (WinningTeam == CS_TEAM_CT)
    		{
    			CPrintToChatAll("%s Counter Terrorist Team wins the round! {orange}!stay{green} or {orange}!switch{green}", PLUGIN_TAG);
    		}
    		return Plugin_Handled;
    	}
      else if(CurrentRound == MATCH)
      {
        CPrintToChatAll("{orange}Enemy Team Health");
        for(int i = 1; i < 11; i++)
        {
          int team = GetClientTeam(i);
          for(int j = 1; j < 11; j++)
          {
            decl String:nick[64];
            GetClientName(j, nick, 32);
            if(IsPlayerAlive(j) && team != GetClientTeam(j))
            {
              CPrintToChat(i, "{green}%s - %iHP", nick, GetClientHealth(j));
            }
            else if(!IsPlayerAlive(j) && team != GetClientTeam(j))
            {
              CPrintToChat(i, "{darkred}%s", nick);
            }
          }
        }
      }
    }

	else if (CurrentRound == WARMUP)
	{
		return Plugin_Handled;
	}

	return Plugin_Handled;
}

public Action WarmupLoadedSMP(Handle timer)
{
  CPrintToChatAll("%s Warmup", PLUGIN_TAG);
}

public Action KnifeRoundRandom(client, cfg)
{
  if(mix)
  {
    ServerCommand("mp_scrambleteams");
  }
	CurrentRound = KNIFE_ROUND;
	ServerCommand("mp_unpause_match");
  ServerCommand("mp_warmup_end");
	ServerCommand("mp_ct_default_secondary none");
	ServerCommand("mp_t_default_secondary none");
	ServerCommand("mp_free_armor 1");
	ServerCommand("mp_roundtime 2");
  ServerCommand("mp_freezetime 5");
	ServerCommand("mp_round_restart_delay 5");
	ServerCommand("mp_roundtime_defuse 2");
	ServerCommand("mp_roundtime_hostage 2");
	ServerCommand("mp_give_player_c4 0");
	ServerCommand("mp_maxmoney 0");
	ServerCommand("mp_restartgame 1");
	ResetValues();
	CreateTimer(2.0, KnifeRoundMessage);
	return Plugin_Handled;
}

public Action KnifeRoundMessage(Handle timer)
{
	CPrintToChatAll("%s \x06KNIFE", PLUGIN_TAG);
	CPrintToChatAll("%s \x06KNIFE", PLUGIN_TAG);
	CPrintToChatAll("%s \x06KNIFE", PLUGIN_TAG);
}

public Action Ladder5on5SMP(client, cfg)
{
  ServerCommand("exec esl5on5");
  if(mix)
  {
    ServerCommand("sv_damage_print_enable 1");
  }
  ServerCommand("mp_restartgame 1");
  ServerCommand("mp_restartgame 4");
	CreateTimer(4.0, MatchMessage);
	return Plugin_Handled;
}

public Action MatchMessage(Handle timer)
{
	CPrintToChatAll("%s \x06LIVE!", PLUGIN_TAG);
	CPrintToChatAll("%s \x06LIVE!", PLUGIN_TAG);
	CPrintToChatAll("%s \x06LIVE!", PLUGIN_TAG);
	CurrentRound = MATCH;
}

public Action TacticPauseSMP(client, args)
{
  int TacticPauseTeam = GetClientTeam(client);
  if(mix)
  {
    if (CurrentRound == MATCH)
  	{
  		if (IsPaused() || !IsClientValid(client))
  		{
  			return Plugin_Handled;
  		}
  		if (TacticPauseTeam == CS_TEAM_CT)
  		{
  					CPrintToChatAll("%s A equipa Contra Terrorista colocou o jogo em pausa.", PLUGIN_TAG);
  					ServerCommand("mp_pause_match");
  					return Plugin_Handled;
  		}
  		else if (TacticPauseTeam == CS_TEAM_T)
  		{
  					CPrintToChatAll("%s A equpa Terrorista colocou o jogo em pausa.", PLUGIN_TAG);
  					ServerCommand("mp_pause_match");
  					return Plugin_Handled;
  		}
  		return Plugin_Handled;
  	}
  }
  else if(!mix)
  {
    if (CurrentRound == MATCH)
  	{
  		if (IsPaused() || !IsClientValid(client))
  		{
  			return Plugin_Handled;
  		}
  		if (TacticPauseTeam == CS_TEAM_CT)
  		{
  					CPrintToChatAll("%s Timeout at freezetime called by Counter Terrorist Team", PLUGIN_TAG);
  					ServerCommand("mp_pause_match");
  					return Plugin_Handled;
  		}
  		else if (TacticPauseTeam == CS_TEAM_T)
  		{
  					CPrintToChatAll("%s Timeout at freezetime called by Terrorist Team", PLUGIN_TAG);
  					ServerCommand("mp_pause_match");
  					return Plugin_Handled;
  		}
  		return Plugin_Handled;
  	}
  }
}

public Action TacticUnpauseSMP(client, args)
{
	if (CurrentRound == MATCH)
	{
		if (!IsPaused() || !IsClientValid(client))
		{
			return Plugin_Handled;
		}
		int team = GetClientTeam(client);
		if (team == CS_TEAM_CT)
		{
				TacticUnpauseCT = true;
		}
		else if (team == CS_TEAM_T)
		{
				TacticUnpauseT = true;
		}
		if (TacticUnpauseCT && TacticUnpauseT)
		{
      UnpauseLock = true;
			return Plugin_Handled;
		}
    if (UnpauseLock == true)
    {
      ServerCommand("mp_unpause_match");
			UnpauseLock = false;
      TacticUnpauseT = false;
      TacticUnpauseCT = false;
			return Plugin_Handled;
    }
    if(mix)
    {
      if (TacticUnpauseCT && !TacticUnpauseT && !UnpauseLock)
  		{
  			CPrintToChatAll("%s Unpause colocado pela equipa Contra Terrorista. Esperando pela equipa Terrorista colocar {orange}!unpause{green}", PLUGIN_TAG);
  			return Plugin_Handled;
  		}
  		else if (!TacticUnpauseCT && TacticUnpauseT && !UnpauseLock)
  		{
  			CPrintToChatAll("%s Unpause colocado pela equipa Terrorista. Esperando pela equipa Contra Terrorista colocar {orange}!unpause{green}", PLUGIN_TAG);
  			return Plugin_Handled;
  		}
    }
    else if(!mix)
    {
      if (TacticUnpauseCT && !TacticUnpauseT && !UnpauseLock)
  		{
  			CPrintToChatAll("%s Unpause called by Counter Terrorist Team. Waiting for Terrorist Team to {orange}!unpause{green}", PLUGIN_TAG);
  			return Plugin_Handled;
  		}
  		else if (!TacticUnpauseCT && TacticUnpauseT && !UnpauseLock)
  		{
  			CPrintToChatAll("%s Unpause called by Terrorist Team. Waiting for Counter Terrorist Team to {orange}!unpause{green}", PLUGIN_TAG);
  			return Plugin_Handled;
  		}
    }
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action WarmupSMP(client, args)
{
  forceready = false;
  escolha = false;
  StayUsed = false;
  SwitchUsed = false;
  ServerCommand("bot_kick");
  ServerCommand("mp_autoteambalance 0");
  ServerCommand("mp_maxmoney 65000");
  ServerCommand("mp_startmoney 65000");
  ServerCommand("mp_free_armor 2");
  ServerCommand("mp_warmuptime 50");
  ServerCommand("mp_warmup_pausetimer 1");
  ServerCommand("mp_warmup_start");
  ResetValues();
  readyT = false;
  readyCT = false;
  CurrentRound = WARMUP;
  CreateTimer(5.0, WarmupLoadedSMP);
}

public OnMapStart()
{
  forceready = false;
  escolha = false;
  StayUsed = false;
  SwitchUsed = false;
  ServerCommand("bot_kick");
  ServerCommand("mp_autoteambalance 0");
  ServerCommand("mp_maxmoney 65000");
  ServerCommand("mp_startmoney 65000");
  ServerCommand("mp_free_armor 2");
  ServerCommand("mp_warmuptime 50");
  ServerCommand("mp_warmup_pausetimer 1");
  ServerCommand("mp_warmup_start");
  ResetValues();
  readyT = false;
  readyCT = false;
  CurrentRound = WARMUP;
  CreateTimer(5.0, WarmupLoadedSMP);
}

public Action Command_sonanet(int client, int args)
{
  if(!escolha)
  {
    CPrintToChatAll("%s {orange}Foi selecionado o modo Pracc!{green}", PLUGIN_TAG);
    escolha = true;
    mix = false;
  }
  else
  {
    if(mix)
    {
      CPrintToChatAll("%s {orange}Foi selecionado o modo Pracc!{green}", PLUGIN_TAG);
      escolha = true;
      mix = false;
    }
  }
}

public Action Command_mirage(int client, int args)
{
  if(mix)
  {
    if(CurrentRound == WARMUP)
    {
      ServerCommand("map de_mirage");
    }
    else
    {
      CPrintToChat(client, "%s Não podes mudar de mapa no decorrer de um jogo.", PLUGIN_TAG);
    }
  }
  else
  {
    CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
  }
}

public Action Command_cache(int client, int args)
{
  if(mix)
  {
    if(CurrentRound == WARMUP)
    {
      ServerCommand("map de_cache");
    }
    else
    {
      CPrintToChat(client, "%s Não podes mudar de mapa no decorrer de um jogo.", PLUGIN_TAG);
    }
  }
  else
  {
    CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
  }
}

public Action Command_dust2(int client, int args)
{
  if(mix)
  {
    if(CurrentRound == WARMUP)
    {
      ServerCommand("map de_dust2");
    }
    else
    {
      CPrintToChat(client, "%s Não podes mudar de mapa no decorrer de um jogo.", PLUGIN_TAG);
    }
  }
  else
  {
    CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
  }
}

public Action Command_inferno(int client, int args)
{
  if(mix)
  {
    if(CurrentRound == WARMUP)
    {
      ServerCommand("map de_inferno");
    }
    else
    {
      CPrintToChat(client, "%s Não podes mudar de mapa no decorrer de um jogo.", PLUGIN_TAG);
    }
  }
  else
  {
    CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
  }
}

public Action Command_overpass(int client, int args)
{
  if(mix)
  {
    if(CurrentRound == WARMUP)
    {
      ServerCommand("map de_overpass");
    }
    else
    {
      CPrintToChat(client, "%s Não podes mudar de mapa no decorrer de um jogo.", PLUGIN_TAG);
    }
  }
  else
  {
    CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
  }
}

public Action Command_train(int client, int args)
{
  if(mix)
  {
    if(CurrentRound == WARMUP)
    {
      ServerCommand("map de_train");
    }
    else
    {
      CPrintToChat(client, "%s Não podes mudar de mapa no decorrer de um jogo.", PLUGIN_TAG);
    }
  }
  else
  {
    CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
  }
}

public Action Command_nuke(int client, int args)
{
  if(mix)
  {
    if(CurrentRound == WARMUP)
    {
      ServerCommand("map de_nuke");
    }
    else
    {
      CPrintToChat(client, "%s Não podes mudar de mapa no decorrer de um jogo.", PLUGIN_TAG);
    }
  }
  else
  {
    CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
  }
}

public Action Command_cbble(int client, int args)
{
  if(mix)
  {
    if(CurrentRound == WARMUP)
    {
      ServerCommand("map de_cbble");
    }
    else
    {
      CPrintToChat(client, "%s Não podes mudar de mapa no decorrer de um jogo.", PLUGIN_TAG);
    }
  }
  else
  {
    CPrintToChat(client, "%s You can't use this command.", PLUGIN_TAG);
  }
}
