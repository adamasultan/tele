function meca1_reset_error(adsClt)
    R1_activate = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Activate');
    R1_deactivate = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Deactivate');
    R1_home = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Home');
    R1_reseterror = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Reset_Error');
    R1_ClearMove = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Motion_Control.Clear_Move');
    R1_resetPstop = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Motion_Control.Reset_PStop');
    
    

    adsClt.WriteAny(R1_reseterror.IndexGroup,R1_reseterror.IndexOffset,true);
    pause(1)
    adsClt.WriteAny(R1_reseterror.IndexGroup,R1_reseterror.IndexOffset,false);
    pause(1)
    
    adsClt.WriteAny(R1_ClearMove.IndexGroup,R1_ClearMove.IndexOffset,true);
    pause(1)
    adsClt.WriteAny(R1_ClearMove.IndexGroup,R1_ClearMove.IndexOffset,false);
    

    adsClt.WriteAny(R1_activate.IndexGroup,R1_activate.IndexOffset,false);
    adsClt.WriteAny(R1_deactivate.IndexGroup,R1_deactivate.IndexOffset,true);
    pause(2)
% 
%     adsClt.WriteAny(R1_reseterror.IndexGroup,R1_reseterror.IndexOffset,true);
%     adsClt.WriteAny(R1_reseterror.IndexGroup,R1_reseterror.IndexOffset,false);
%     pause(2)
% 
    adsClt.WriteAny(R1_deactivate.IndexGroup,R1_deactivate.IndexOffset,false);
    adsClt.WriteAny(R1_activate.IndexGroup,R1_activate.IndexOffset,true);
    pause(2)

    adsClt.WriteAny(R1_home.IndexGroup,R1_home.IndexOffset,true);    
%     
%     A = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Activated'));
%     if A == 0
%         R1_activate = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Activate');
%         R1_deactivate = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Deactivate');
%         adsClt.WriteAny(R1_activate.IndexGroup,R1_activate.IndexOffset,true);
%         adsClt.WriteAny(R1_deactivate.IndexGroup,R1_deactivate.IndexOffset,false);
%         while A == 0
%             pause(1);
%             A = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Activated'));
%         end
%     end
%     disp("Robot1 Activated");
%     
%     H = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Homed'));
%     if H == 0
%         R1_home = adsClt.ReadSymbolInfo('GVL.Robot1.Outputs.Robot_Control.Home');
%         adsClt.WriteAny(R1_home.IndexGroup,R1_home.IndexOffset,true);    
%         while H == 0
%             pause(1);
%             H = adsClt.ReadSymbol(adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Robot_Status.Homed'));
%         end
%     end
%     disp("Robot1 Homed");
end

    