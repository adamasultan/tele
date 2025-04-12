function meca2_ETC_Shutdown(adsClt)
    R2_activate = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Robot_Control.Activate');
    R2_deactivate = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Robot_Control.Deactivate');
    R2_home = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Robot_Control.Home');
    R2_reseterror = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Robot_Control.Reset_Error');
    R2_ClearMove = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Motion_Control.Clear_Move');
    R2_resetPstop = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Motion_Control.Reset_PStop');
    Move_command = adsClt.ReadSymbolInfo('Main.Values'); 
    
    B = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Busy'));    
    cntr = 0;
    while B ~= 0 && cntr < 10
        pause(1)
        B = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Busy'));
        cntr = cntr + 1
    end
    if B ~= 0 && cntr == 10
        disp("Robot2 is Busy!")
        return
    end

    E = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Error'));
    if E ~= 0
        adsClt.WriteAny(R2_reseterror.IndexGroup,R2_reseterror.IndexOffset,true);
        cntr = 0;
        while E ~= 0 && cntr < 10            
            pause(1)
            cntr = cntr + 1;
            E = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Error'));            
        end
        if E ~= 0 && cntr == 10
            disp("Robot2 is in Error state!")
            return
        end
        adsClt.WriteAny(R2_reseterror.IndexGroup,R2_reseterror.IndexOffset,false);
        pause(1)
    end

    % clearing the move command
    values=[0 0 0 0 0 0 0 32010 32011 1 2];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values));       
    
    adsClt.WriteAny(R2_ClearMove.IndexGroup,R2_ClearMove.IndexOffset,true);
    pause(1)
    adsClt.WriteAny(R2_ClearMove.IndexGroup,R2_ClearMove.IndexOffset,false);
    
    adsClt.WriteAny(R2_home.IndexGroup,R2_home.IndexOffset,false);   
    
    adsClt.WriteAny(R2_activate.IndexGroup,R2_activate.IndexOffset,false);
    adsClt.WriteAny(R2_deactivate.IndexGroup,R2_deactivate.IndexOffset,true);
    pause(2)  
     
     
end

