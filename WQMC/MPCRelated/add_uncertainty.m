function value_unc = add_uncertainty(qext, qunc)
    ql=qext-qunc*qext;
    qu=qext+qunc*qext;
    value_unc=ql+rand(1,length(qext)).*(qu-ql);
end
