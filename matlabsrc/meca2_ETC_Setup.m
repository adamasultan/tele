function meca2_ETC_Setup(adsClt)
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
        R2_reseterror = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Robot_Control.Reset_Error');
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
    end


    A = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Activated'));    
    E = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Error'));
    R2_activate = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Robot_Control.Activate');
    R2_deactivate = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Robot_Control.Deactivate');
    if A == 0 && E == 0
        adsClt.WriteAny(R2_deactivate.IndexGroup,R2_deactivate.IndexOffset,false);
        adsClt.WriteAny(R2_activate.IndexGroup,R2_activate.IndexOffset,true);
        while A == 0
            pause(1);
            A = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Activated'));
        end  
    end
    adsClt.WriteAny(R2_activate.IndexGroup,R2_activate.IndexOffset,false);
    disp("Robot2 Activated");
    
    H = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Homed'));
    E = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Error'));
    R2_home = adsClt.ReadSymbolInfo('GVL.Robot2.Outputs.Robot_Control.Home');
    if H == 0 && E == 0
        adsClt.WriteAny(R2_home.IndexGroup,R2_home.IndexOffset,true);    
        while H == 0
            pause(1);
            H = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Robot_Status.Homed'));
        end
    end
    adsClt.WriteAny(R2_home.IndexGroup,R2_home.IndexOffset,false);   
    disp("Robot2 Homed");    
end

