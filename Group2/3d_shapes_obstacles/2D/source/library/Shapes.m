classdef Shapes < matlab.mixin.Heterogeneous & handle
    % matlab.mixin.Heterogeneous = cho phép mảng chứa nhiều loại object con khác nhau.
    %handle cho phép object tham chiếu, không copy khi biến đc gán thay đổi
    %thì những giá bị dùng để gán cũng thay đổi theo

    properties
        position %vị trí hiện tại của vật cản
        velocity %vận tốc hiện tại
        velocityFunction % hàm vận quy luật vận tốc theo thời gian

        gamma     %hàm gamma mô tả shape function 
        Gradientgamma %hàm gadient ( đạo hàm để biết hướng của bề mặt)
        gammaDistance %Hàm khoảng cách từ 1 điểm đến shape
        shapeParameters %tham số hình học của vật cản

        rho            % hệ số mật độ
        patchVal       %dùng handle để vẽ vật thể 3d
        prevTime       %lưu thời gian trước đó để tính delta_t khi cập nhật động học.

    end

    methods
        function self = Shapes(gamma,Gradientgamma,gammaDistance,parameters,position,velocityFunction,rho)
            if nagin >0
                if size(position) ==3 % nếu matran position có 3 cột [x,y,z]
                    position=position';
                end
                self.position=position;
                self.velocity=velocityFunction;
                self.velocity = [0; 0; 0];

                self.shapeParameters = parameters;

                self.prevTime=0;
                self.gamma = @(x,y,z) gamma(x-self.position(1),y-self.position(2),z-self.position(2),parameters);
                self.Gradientgamma=@(x,y,z) Gradientgamma(x-self.position(1),y-self.position(2),z-self.position(2),parameters);
                self.gammaDistance=@(x,y,z) gammaDistance(x-self.position(1),y-self.position(2),z-self.position(2),parameters);
                if exist('rho', 'var') == true
                  self.rho = rho;
                end
 
            end

        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end