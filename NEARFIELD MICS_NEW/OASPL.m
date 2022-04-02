function [OA] = OASPL(f,SPL)
DLA = -145.528 + 98.262*log(f)-19.509(log(f)).*2 + 0.975*(log(f)).*3;
temp1 = 10*((SPL+DLA)/10);
OA = 10*log(sum(temp1));
end
