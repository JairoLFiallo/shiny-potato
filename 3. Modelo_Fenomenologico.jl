using Plots

default(fontfamily="Computer Modern")

x_grid = 0:0.1:60   
y_grid = 0:0.1:120

y_cilindros = [26.0, 50.5, 75.4, 100.1]
x_c = 50.0
f = 6.25            
V_in = 21.5         
V_max = 21.5        

function campo_velocidad(x, y)

    for yc in y_cilindros
        if (x - x_c)^2 + (y - yc)^2 <= f^2
            return 0.0 
        end
    end

    if x >= x_c
        distancia_x = x - x_c
        return V_in + (V_max - V_in) * exp(-(distancia_x^2) / 25.0)
    end

    deficit_total = 0.0
    dist_x = x_c - x
    
    for yc in y_cilindros
        ensanchamiento = 2.0 + 0.15 * dist_x
        max_deficit = (V_max - 5.0) * exp(-0.06 * dist_x) 
        
        deficit_total += max_deficit * exp(-((y - yc)^2) / (2 * ensanchamiento^2))
    end

    v_local = V_max - deficit_total
    return max(0.0, v_local)
end

Z = [campo_velocidad(x, y) for y in y_grid, x in x_grid]

p_cfd = contourf(x_grid, y_grid, Z,
    levels=40,               
    color=:turbo,            
    linewidth=0,             
    xlabel="Distancia longitudinal x (mm)",
    ylabel="Altura transversal y (mm)",

    size=(1000, 1000),
    # ratio=:equal,
    dpi=1000,
    
    colorbar_title=" \nMagnitud de Velocidad (m/s)",
    clims=(0, 22),           

    left_margin=7.5Plots.mm,   
    bottom_margin=0.001Plots.mm, 
    right_margin=7.5Plots.mm  
)

theta = range(0, 2pi, length=50)
for yc in y_cilindros
    x_circle = x_c .+ f .* cos.(theta)
    y_circle = yc .+ f .* sin.(theta)
    plot!(p_cfd, x_circle, y_circle, 
          seriestype=:shape, fillcolor=:silver, linecolor=:black, lw=1.5, legend=false)
end

#savefig(p_cfd, joinpath(@__DIR__, "simulacion.pdf"))
display(p_cfd)
