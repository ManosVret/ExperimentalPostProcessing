% function [OA] = OASPL(f,SPL)
% DLA = -145.528 + 98.262*log(f)-19.509*(log(f)).^2 + 0.975*(log(f)).^3;
% temp1 = 10.^((SPL+DLA)/10);
% OA = 10*log(sum(temp1));
% end

function [OA] = OASPL(opp,MIC,rud,logic)
for i = 1:sum(logic)
    f = MIC{rud}.f{i};
    PL = MIC{rud}.SPL{i};
    DLA = -145.528 + 98.262*log(f)-19.509*(log(f)).^2 + 0.975*(log(f)).^3;
    temp1 = 10.^((PL+DLA)/10);
    OA(i) = mean(10*log(sum(temp1)),2);
end
end 