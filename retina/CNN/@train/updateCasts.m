function run=updateCasts( run )
%classT = getVarTypeOfCNN( run ) Get variable type to use for a CNN obj
%during GPU operation (classT1) and during CPU operation (classT2)
if run.double
    if run.GPU
        run.wghtTyp = @gdouble;
    else
        run.wghtTyp = @double;
    end
    if run.GPU
        run.actvtTyp = @gdouble;
    else
        run.actvtTyp = @double;
    end    
    run.saveTyp=@double;
else
    if run.GPU
        run.wghtTyp = @gsingle;
    else
        run.wghtTyp = @single;
    end
    if run.GPU
        run.atvtTyp = @gsingle;
    else
        run.atvtTyp= @single;
    end 
    run.saveTyp=@single;
end

end

