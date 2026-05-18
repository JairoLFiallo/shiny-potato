using CSV
using DataFrames
using Plots
using Interpolations
using Trapz
using Measures

# Tus defaults exactos, con la fuente Computer Modern restaurada
default(
    fontfamily = "Computer Modern",
    grid = true,
    
    # --- Tamaños de Letra ---
    guidefontsize = 13,    # Tamaño de los títulos de los ejes (X y Y)
    tickfontsize = 10,      # Tamaño de los números en los ejes
    legendfontsize = 10,    # Tamaño del texto dentro del cuadrito de la leyenda
    
    # --- Tamaños de Íconos ---
    markersize = 5,        # Tamaño de los círculos de tus datos
    linewidth = 2.7,       # Grosor de las líneas de ajuste
    
    # --- Márgenes ---
    left_margin = 10mm,     
    bottom_margin = 10mm,   
    right_margin = 8mm,
    top_margin = 2mm
)

# 1. Lectura robusta de datos
ruta_archivo = joinpath(@__DIR__, "exp3_perfil.dat")
texto_limpio = replace(read(ruta_archivo, String), "\t" => " ")
df = CSV.read(IOBuffer(texto_limpio), DataFrame, delim=' ', ignorerepeated=true)

# Extraer vectores
y_pos = df.Posicion     # Altura en mm
V_vel = Float64.(df.Velocidad)    # Aseguramos que la velocidad sea Float

# 2. Integración Numérica (Regla del Trapecio con datos crudos)
area_trapz = trapz(y_pos, V_vel)
altura_total = y_pos[end] - y_pos[1]
v_media_trapz = area_trapz / altura_total

# 3. Modelo de Splines Cúbicos
y_rango = y_pos[1]:2:y_pos[end]
itp = cubic_spline_interpolation(y_rango, V_vel, extrapolation_bc=Line())

y_continua = range(minimum(y_pos), maximum(y_pos), length=800)
V_continua = itp.(y_continua)

area_spline = trapz(y_continua, V_continua)
v_media_spline = area_spline / altura_total

println("--- Resultados de Integración Numérica ---")
println("Velocidad Media (Regla Trapecio discreta): $(round(v_media_trapz, digits=4)) m/s")
println("Velocidad Media (Splines Cúbicos):       $(round(v_media_spline, digits=4)) m/s")

# --- Graficación del Perfil (Esquema Conceptual Híbrido) ---

# 1. Posiciones físicas
y_cilindros = [26.0, 50.5, 75.4, 100.1]
# Colocamos el banco de tubos en una línea imaginaria a la derecha
x_banco = fill(24.0, length(y_cilindros)) 

# Extraemos la velocidad exacta en esos puntos para conectar las líneas
v_valles = itp.(y_cilindros)

# 2. Lienzo Base (Cambiamos el tamaño para que parezca un plano)
p_perfil = plot(
    xlabel="Velocidad Transversal V_2 (m/s)",
    ylabel="Altura en la sección y (mm)",
    size=(1000, 1200), 
    dpi=1000,
    legend=false, 
    xticks = 4:1:24,
    yticks = 0:5:120,
    
    # --- LA MAGIA DEL ESPACIO ---
    xlims = (4, 26),       # Forzamos que el eje X llegue más allá de los cilindros
    right_margin = 5mm      # Aumentamos el margen derecho drásticamente
)

# 3. Dibujamos las líneas de "sombra aerodinámica" (Estelas)
for i in eachindex(y_cilindros)
    plot!(p_perfil, [v_valles[i], x_banco[i]], [y_cilindros[i], y_cilindros[i]], 
          color=:gray, linestyle=:dash, lw=1.5)
end

# 4. Dibujamos los Cilindros Físicos
scatter!(p_perfil, x_banco, y_cilindros, 
    marker=:circle, markersize=58, color=:silver, 
    markerstrokecolor=:black, markerstrokewidth=2)

# 5. El Perfil de Velocidad con EFECTO HEATMAP
# Usamos `line_z` para mapear el valor de la velocidad a un color
plot!(p_perfil, V_continua, y_continua, 
    linewidth=6, 
    line_z=V_continua,      # Pinta la línea basándose en su valor X
    color=:turbo,           # Escala de colores clásica en dinámica de fluidos
    colorbar=true,
    colorbar_title=" \n Magnitud (m/s)"
)

# 6. Tus puntos experimentales encima (en negro para dar contraste)
scatter!(p_perfil, V_vel, y_pos, 
    marker=:circle, markersize=5, color=:black, markerstrokewidth=0)

# Exportar y mostrar
#savefig(p_perfil, joinpath(@__DIR__, "grafica_hibrida_presentacion_alargada.pdf"))
display(p_perfil)