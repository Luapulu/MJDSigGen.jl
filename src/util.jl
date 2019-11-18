# This file is a part of MJDSigGen, licensed under the MIT License (MIT).

function tuplestr(s::NTuple{N,Cchar}) where {N}
    a = [c % UInt8 for c in s]
    from = findfirst(x -> x != 0, a)
    to = something(findfirst(x -> x == 0, a[from:lastindex(a)]), lastindex(a) + 1) - 1
    String(a[from:from + to-1])
end


field_file_name(setup, path_to_config) = 
    joinpath(dirname(path_to_config), tuplestr(setup.field_name))

wpot_file_name(setup, path_to_config) = 
    joinpath(dirname(path_to_config), tuplestr(setup.wp_name))

function read_fields(setup, path_to_config)
    field_data = readdlm(field_file_name(setup), comments=true)
    wpot_data = readdlm(wpot_file_name(setup), comments=true)
    n_r = setup.rlen
    n_z = setup.zlen
    @assert (size(field_data, 1) == size(wpot_data, 1) == n_r * n_z)

    E_pot = copy(reshape(view(field_data, :, 3), (n_z, n_r)))
    W_pot = copy(reshape(view(wpot_data, :, 3), (n_z, n_r)))

    E_abs = copy(reshape(view(field_data, :, 4), (n_z, n_r)))
    E_r = copy(reshape(view(field_data, :, 5), (n_z, n_r)))
    E_z = copy(reshape(view(field_data, :, 6), (n_z, n_r)))

    E_pot, W_pot, E_abs, E_r, E_z
end


cyl2cart(r, ϕ, z) = (r * cos(ϕ), r * sin(ϕ), z)


function cart2cyl(x, y, z)
    r = √(x^2 + y^2)
    if x == 0
        ϕ = (y > 0) ? π/2 : -π/2
    else
        ϕ = (x < 0) ? atan(y/x) + π : atan(y/x)
    end
    (r, ϕ, z)
end
