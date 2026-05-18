using Plots
using Measures

default(
    fontfamily = "Computer Modern",
    grid = true,

    guidefontsize = 16,    
    tickfontsize = 16,      
    legendfontsize = 16,

    linewidth = 2.7,       
    left_margin = 13Plots.mm,     
    bottom_margin = 12Plots.mm,   
    right_margin = 6Plots.mm,
    top_margin = 4Plots.mm
)

D = 0.0125
L = 0.125
rho_cu = 8960.0
cp_cu = 385.0
As = pi * D * L
Vol = (pi * D^2 / 4) * L
m = rho_cu * Vol

nu_aire = 1.7e-5
k_aire = 0.026
Pr = 0.707

V = 20.64
Re = (V * D) / nu_aire

Nu = 0.3 + ((0.62 * Re^0.5 * Pr^(1/3)) / (1 + (0.4/Pr)^(2/3))^0.25) * (1 + (Re/282000)^(5/8))^(4/5)
h = (Nu * k_aire) / D

Ti = 80.0           # Temperatura inicial (°C)
T_inf = 24.5        # Temperatura ambiente (°C)
t = 0:1:150         # Tiempo de simulación (s)

tau = (m * cp_cu) / (h * As)  
T_t = T_inf .+ (Ti - T_inf) .* exp.(-t ./ tau)

p_enfriamiento = plot(
    xlabel="Tiempo t (s)", 
    ylabel="Temperatura T (°C)",
    size=(1600, 800),
    dpi=600,
    xticks=0:10:150,
    yticks=20:5:80,
    legend=:topright,
    framestyle=:box
)

hline!(p_enfriamiento, [T_inf], 
       label="T. Ambiente (24.5 °C)", 
       color=:gray, linestyle=:dash, lw=2.0)

plot!(p_enfriamiento, t, T_t, 
      color=:darkorange,
      label="Capacitancia Global (h = $(round(h, digits=2)) W/m^2K)")

display(p_enfriamiento)
#savefig(p_enfriamiento, joinpath(@__DIR__, "prediccion_enfriamiento.pdf"))

println("Simulación terminada. Coeficiente h predicho: $h W/m²K")
