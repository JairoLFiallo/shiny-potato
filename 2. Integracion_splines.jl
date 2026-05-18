using CSV
using DataFrames
using Plots
using Interpolations
using Trapz
using Measures

default(
    fontfamily = "Computer Modern",
    grid = true,

    guidefontsize = 13,
    tickfontsize = 10,
    legendfontsize = 10,

    markersize = 5,
    linewidth = 2.7,

    left_margin = 10mm,     
    bottom_margin = 10mm,   
    right_margin = 8mm,
    top_margin = 2mm
)

ruta_archivo = joinpath(@__DIR__, "exp3_perfil.dat")
texto_limpio = replace(read(ruta_archivo, String), "\t" => " ")
df = CSV.read(IOBuffer(texto_limpio), DataFrame, delim=' ', ignorerepeated=true)

y_pos = df.Posicion
V_vel = Float64.(df.Velocidad)

area_trapz = trapz(y_pos, V_vel)
altura_total = y_pos[end] - y_pos[1]
v_media_trapz = area_trapz / altura_total

y_rango = y_pos[1]:2:y_pos[end]
itp = cubic_spline_interpolation(y_rango, V_vel, extrapolation_bc=Line())

y_continua = range(minimum(y_pos), maximum(y_pos), length=800)
V_continua = itp.(y_continua)

area_spline = trapz(y_continua, V_continua)
v_media_spline = area_spline / altura_total

println("--- Resultados de Integración Numérica ---")
println("Velocidad Media (Regla Trapecio discreta): $(round(v_media_trapz, digits=4)) m/s")
println("Velocidad Media (Splines Cúbicos):       $(round(v_media_spline, digits=4)) m/s")

y_cilindros = [26.0, 50.5, 75.4, 100.1]

x_banco = fill(24.0, length(y_cilindros)) 

v_valles = itp.(y_cilindros)

p_perfil = plot(
    xlabel="Velocidad Transversal V_2 (m/s)",
    ylabel="Altura en la sección y (mm)",
    size=(1000, 1200), 
    dpi=1000,
    legend=false, 
    xticks = 4:1:24,
    yticks = 0:5:120,

    xlims = (4, 26),
    right_margin = 5mm
)

for i in eachindex(y_cilindros)
    plot!(p_perfil, [v_valles[i], x_banco[i]], [y_cilindros[i], y_cilindros[i]], 
          color=:gray, linestyle=:dash, lw=1.5)
end

scatter!(p_perfil, x_banco, y_cilindros, 
    marker=:circle, markersize=58, color=:silver, 
    markerstrokecolor=:black, markerstrokewidth=2)

plot!(p_perfil, V_continua, y_continua, 
    linewidth=6, 
    line_z=V_continua,
    color=:turbo,
    colorbar=true,
    colorbar_title=" \n Magnitud (m/s)"
)

scatter!(p_perfil, V_vel, y_pos, 
    marker=:circle, markersize=5, color=:black, markerstrokewidth=0)

#savefig(p_perfil, joinpath(@__DIR__, "grafica_hibrida.pdf"))
display(p_perfil)
