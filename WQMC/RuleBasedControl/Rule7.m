% This rule is for the concentration = 0.5(sunction + deliver)
if(Error_Level < -2) % stop, dangerous situaiton since it begin to diverge
    disp('Warning: Diverging and STOP!!!');
end

if(Error_Level <= -1.5 && Error_Level >= -2  ) 
    U_rbc = 12;
end

if(Error_Level <= -1.2 && Error_Level > -1.5  ) 
    U_rbc = 12;
end

if(Error_Level <= -1.0 && Error_Level > -1.2  ) 
    U_rbc = 12;
end

if(Error_Level <= -0.8 && Error_Level > -1.0  ) 
    U_rbc = 10;
end

if(Error_Level <= -0.5 && Error_Level > -0.8  ) 
    U_rbc = 8;
end

if(Error_Level <= -0.2 && Error_Level > -0.5  ) 
    U_rbc = 5.5;
end

if(Error_Level < -0.0 && Error_Level > -0.2  ) 
    U_rbc = 2;
end

if(Error_Level >= 0 ) 
    U_rbc = 0;
end
U_rbc= U_rbc*3;

