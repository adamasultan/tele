function adsClt = start_ads_client()
    % Suppress warnings
    warning off;
    
    % TwinCAT setup for Meca Robots
    global adsClt Move_command 
    global R1_px R1_py R1_pz R1_rx R1_ry R1_rz

    % Load TwinCAT.Ads.dll
    asm = NET.addAssembly('C:\Users\biom-admin\Desktop\Hoorieh\P3_v1_April_2024\TwinCAT.Ads.dll');
    import TwinCAT.Ads.*;

    % Create an ADS client
    adsClt = TwinCAT.Ads.TcAdsClient;
    adsClt.Connect('192.168.0.153.1.1', 851);

    % Display connection status
    disp('ADS Client Connected');

end
