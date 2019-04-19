function [angle] = ET250_3D(cmd, angle)


switch cmd
    
    case 'udp_start'
        echoudp('on',7000)
        u = udp('192.168.1.34',7000);
        fopen(u)
                            
        
    case 'set'
        %request current position
        fwrite(u,hex2dec(['04';'00';'00';'04']))
        x = fread(u,7);
        angle_current = (x(4)*256+x(5))/10;

        %calc shortest way
        angle_delta = angle-angle_current;
        if angle_delta > 180
            angle_delta = angle_delta - 360;
        end
        if angle_delta < -180
            angle_delta = angle_delta + 360;
        end

        cmd(1) = uint8( 1.5-sign(angle_delta)/2 );                %1st byte = direction
        cmd(2) = uint8( floor(abs(angle_delta*10)/256) );         %angle in degree*10
        cmd(3) = uint8( mod(floor(abs(angle_delta*10)),256) );    %angle in degree*10
        cmd(4) = 0;

        fwrite(u,cmd)
        x = dec2hex(fread(u,2));                            %receive ACK
 
        
    case 'get'
        %request current position
        fwrite(u,hex2dec(['04';'00';'00';'04']))
        x = fread(u,7);
        angle = (x(4)*256+x(5))/10;
    
    case 'stop'
        fwrite(u,hex2dec(['03';'00';'00';'03']))            %send stop stop
        x = dec2hex(fread(u,2));      
        
    case 'udp_stop'
        echoudp('off')
        fclose(u)
end

        
end
