function meca1_ETC_Setup(adsClt)
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
        R1_reseterror = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Reset_Error');
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
    end


    A = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Activated'));    
    E = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Error'));
    R1_activate = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Activate');
    R1_deactivate = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Deactivate');
    if A == 0 && E == 0
        adsClt.WriteAny(R1_deactivate.IndexGroup,R1_deactivate.IndexOffset,false);
        adsClt.WriteAny(R1_activate.IndexGroup,R1_activate.IndexOffset,true);
        while A == 0
            pause(1);
            A = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Activated'));
        end  
    end
    adsClt.WriteAny(R1_activate.IndexGroup,R1_activate.IndexOffset,false);
    disp("Robot1 Activated");
    
    H = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Homed'));
    E = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Error'));
    R1_home = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Home');
    if H == 0 && E == 0
        adsClt.WriteAny(R1_home.IndexGroup,R1_home.IndexOffset,true);    
        while H == 0
            pause(1);
            H = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Homed'));
        end
    end
    adsClt.WriteAny(R1_home.IndexGroup,R1_home.IndexOffset,false);   
    disp("Robot1 Homed");    
end

