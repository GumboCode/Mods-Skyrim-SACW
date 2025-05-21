Scriptname GM_SACW_SKSE_MCM_Settings extends SKI_ConfigBase

{This is a MCM that sets the value of a global variable that controls the magnitude of a spell, then applies the spell.}

; =============================================================
; VARIABLES
; =============================================================

; Properties -----------------------------------------------------

Actor           property    _PLAYERREF     auto
{Set this to the player reference.}

GlobalVariable  property    _GLOBAL1_MAG  auto
{The global to pull the magnitude from.}

Spell           property    _SPELL1      auto
{The spell to apply directly to the player.}

; Private -----------------------------------------------------

; IDs
int     _slider1id_i
int     _input1id_i

; Stored
int     _mag_i
int     _max_i      = 10000000
int     _min_i      = 0

string  _mag_s

; =============================================================
; EVENTS
; =============================================================

; Initial -----------------------------------------------------

event OnConfigInit()

    ModName = "Simple Add CW"
    Pages = new string[1]
    Pages[0] = "Settings"

endEvent

; Pages -----------------------------------------------------

event OnPageReset(string a_page)

    ; || Logo ||
    
    if (a_page == "")
    
        LoadCustomContent("GumboMods/SimpleAddCarryWeight/SACW_logo.dds")
    
    else
    
        UnloadCustomContent()
    
    endif
    
    ; || Settings ||
    
    if (a_page == "Settings")
    
        _mag_i = _GLOBAL1_MAG.GetValueInt()
        _mag_s = _mag_i as string   ;converts the integer to a string to be used by the input option

        SetCursorFillMode(TOP_TO_BOTTOM)
		
        AddHeaderOption("Configure")
        _slider1id_i = AddSliderOption("Incrementally Set Carry Weight", _mag_i)
        _input1id_i = AddInputOption("Manually Set Carry Weight", _mag_s)
		
    endif

endEvent

; Default -----------------------------------------------------

event OnOptionDefault(int a_option)

    _GLOBAL1_MAG.SetValue(0)
    CastTheSpell()
    ForcePageReset()

endEvent

; Info -----------------------------------------------------

event OnOptionHighlight(int a_option)

    if (a_option == _slider1id_i)
    
        SetInfoText("Set the amount of carry weight to add by increments of 500K. Maximum is 10M")
    
    elseif (a_option == _input1id_i)
    
        SetInfoText("Set the amount of carry weight to add by custom entry. No negative values. Maximum is 10M.")
    
    endif

endEvent

; Sliders -----------------------------------------------------

event OnOptionSliderOpen(int a_option)

    if (a_option == _slider1id_i)
    
        SetSliderDialogStartValue(_mag_i)
        SetSliderDialogDefaultValue(_min_i)
        SetSliderDialogRange(_min_i, _max_i)
        SetSliderDialogInterval(500000)
        
    endIf

endEvent



event OnOptionSliderAccept(int a_option, float a_value)
		
	if (a_option == _slider1id_i)
    
        _GLOBAL1_MAG.SetValue(a_value)
        CastTheSpell(a_value)   ;calls a function that exist inside this script and passes a float to it
        
	endIf
    
    ForcePageReset()
    
endEvent

; Inputs -----------------------------------------------------

event OnOptionInputOpen(int a_option)

    if (a_option == _input1id_i)
    
        SetInputDialogStartText(_mag_s)
    
    endif

endEvent

event OnOptionInputAccept(int a_option, string a_input)

    if (a_option == _input1id_i)
    
        float _float1 = a_input as float	;cast the input string as a float to set the global variable
        
        if (_float1 < _min_i)    ;make sure the user input stays between minimum value and maximum value
        
            _float1 = _min_i
            
        elseif (_float1 > _max_i)
        
            _float1 = _max_i
        
        endif
        
		_GLOBAL1_MAG.SetValue(_float1)
        CastTheSpell(_float1)
    
    endif

    ForcePageReset()

endEvent

; =============================================================
; FUNCTIONS
; =============================================================

Function CastTheSpell(float a_value = 0.0)    ;function that applies the spell to the player
    
    _PLAYERREF.RemoveSpell(_SPELL1)     ;removes the spell so it can be reapplied with new values
    if (a_value > 0)    ;only apply the spell if the input value is more than 0
    
        _SPELL1.SetNthEffectMagnitude(0, _GLOBAL1_MAG.GetValue())  ;skse function that can temporarily set the magnitude of a spell
        _PLAYERREF.AddSpell(_SPELL1)
    
    endif
    
endFunction