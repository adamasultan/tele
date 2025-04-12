function meca1_ETC_Shutdown(adsClt)
    R1_activate = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Activate');
    R1_deactivate = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Deactivate');
    R1_home = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Home');
    R1_reseterror = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Reset_Error');
    R1_ClearMove = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Motion_Control.Clear_Move');
    R1_resetPstop = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Motion_Control.Reset_PStop');
    Move_command = adsClt.ReadSymbolInfo('Main.Values'); 
    
    B = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Busy'));    
    cntr = 0;
    while B ~= 0 && cntr < 10
        pause(1)
        B = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Busy'));
        cntr = cntr + 1
    end
    if B ~= 0 && cntr == 10
        disp("Robot1 is Busy!")
        return
    end

    E = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Error'));
    if E ~= 0
        adsClt.WriteAny(R1_reseterror.IndexGroup,R1_reseterror.IndexOffset,true);
        cntr = 0;
        while E ~= 0 && cntr < 10            
            pause(1)
            cntr = cntr + 1;
            E = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Error'));            
        end
        if E ~= 0 && cntr == 10
            disp("Robot1 is in Error state!")
            return
        end
        adsClt.WriteAny(R1_reseterror.IndexGroup,R1_reseterror.IndexOffset,false);
        pause(1)
    end

    % clearing the move command
    values=[0 0 0 0 0 0 0 32010 32011 1 1];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values));       
    
    adsClt.WriteAny(R1_ClearMove.IndexGroup,R1_ClearMove.IndexOffset,true);
    pause(1)
    adsClt.WriteAny(R1_ClearMove.IndexGroup,R1_ClearMove.IndexOffset,false);
    
    adsClt.WriteAny(R1_home.IndexGroup,R1_home.IndexOffset,false);   
    
    adsClt.WriteAny(R1_activate.IndexGroup,R1_activate.IndexOffset,false);
    adsClt.WriteAny(R1_deactivate.IndexGroup,R1_deactivate.IndexOffset,true);
    pause(2)
     
     
end

