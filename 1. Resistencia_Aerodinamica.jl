using CSV
using DataFrames
using LsqFit
using Plots
using Measures

# Aquí controlas absolutamente toda la estética global:
default(
    fontfamily = "Computer Modern",
    grid = true,
    
    # --- Tamaños de Letra ---
    guidefontsize = 10,    # Tamaño de los títulos de los ejes (X y Y)
    tickfontsize = 9,     # Tamaño de los números en los ejes
    legendfontsize = 9,   # Tamaño del texto dentro del cuadrito de la leyenda
    
    # --- Tamaños de Íconos ---
    markersize = 5,        # Tamaño de los círculos de tus datos
    linewidth = 2.7,       # Grosor de las líneas de ajuste
    
    # --- Márgenes (La solución al texto cortado) ---
    left_margin = 4mm,     # Empuja la gráfica a la derecha para que quepa el label Y
    bottom_margin = 6mm,   # Empuja hacia arriba para que quepa el label X
    right_margin = 2mm,
    top_margin = 2mm
)

function analizar_aerodinamica(archivo_dat, etiqueta_nombre, color_elegido)
    
    texto_limpio = replace(read(archivo_dat, String), "\t" => " ")
    df = CSV.read(IOBuffer(texto_limpio), DataFrame, delim=' ', ignorerepeated=true)
    
    V = df.Velocidad
    dP = abs.(df.CaidaPresion) 
    
    @. modelo_presion(V, p) = p[1] * V^p[2]
    
    p0 = [1.0, 2.0]
    ajuste = curve_fit(modelo_presion, V, dP, p0)
    a_opt, b_opt = ajuste.param
    
    println("--- Resultados para: $etiqueta_nombre ---")
    println("Ecuación ajustada: ΔP = $(round(a_opt, digits=4)) * V ^ $(round(b_opt, digits=3))")
    
    # Creamos la gráfica individual y la guardamos en la variable "p_indiv"
    p_indiv = scatter(V, dP, label="Datos: $etiqueta_nombre", marker=:circle, color=color_elegido, markerstrokecolor=:black, legend=:topleft)
    
    V_rango = range(minimum(V), maximum(V), length=100)
    plot!(p_indiv, V_rango, modelo_presion(V_rango, ajuste.param), 
          label="Ajuste (b = $(round(b_opt, digits=2)))", 
          lw=2, color=color_elegido,
          xlabel="Velocidad Media V (m/s)",
          ylabel="Caída de Presión Δp (Pa)") # Etiqueta un poco más corta para que no choque
          
    return p_indiv
end

# --- Ejecución ---
ruta_banco    = joinpath(@__DIR__, "exp1_banco.dat")
ruta_frio     = joinpath(@__DIR__, "exp1_cobre_frio.dat")
ruta_caliente = joinpath(@__DIR__, "exp1_cobre_caliente.dat")

# 1. Generamos las 3 gráficas por separado
plot_banco    = analizar_aerodinamica(ruta_banco, "Banco Completo", :dodgerblue)
plot_frio     = analizar_aerodinamica(ruta_frio, "Cobre Frío", :darkorange)
plot_caliente = analizar_aerodinamica(ruta_caliente, "Cobre Caliente", :firebrick)

# 2. Definimos la cuadrícula personalizada: a y b arriba, c abajo ocupando todo el ancho
l = @layout [a b; c]

# 3. Ensamblamos la gráfica final pasándole el orden (frio=a, caliente=b, banco=c)
plot_final = plot(plot_frio, plot_caliente, plot_banco, layout=l, size=(1920, 850), dpi=1000)

# 4. Mostrar y exportar (PDF sigue siendo el rey para LaTeX)
display(plot_final)
savefig(plot_final, "grafica_combinada_presentacion.pdf")