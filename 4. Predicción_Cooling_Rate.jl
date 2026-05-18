using Plots
using Measures

# --- Configuración Estética Global ---
default(
    fontfamily = "Computer Modern",
    grid = true,
    
    # --- Tamaños de Letra ---
    guidefontsize = 16,    
    tickfontsize = 16,      
    legendfontsize = 16, # Reducido un poco para que no abrume la curva
    
    # --- Grosores y Márgenes ---
    linewidth = 2.7,       
    left_margin = 13Plots.mm,     
    bottom_margin = 12Plots.mm,   
    right_margin = 6Plots.mm,
    top_margin = 4Plots.mm
)

# --- 1. Propiedades Físicas ---
D = 0.0125          # Diámetro (m)
L = 0.125           # Longitud (m)
rho_cu = 8960.0     # Densidad del cobre (kg/m^3)
cp_cu = 385.0       # Calor específico (J/kg·K)
As = pi * D * L     # Área superficial (m^2)
Vol = (pi * D^2 / 4) * L  # Volumen (m^3)
m = rho_cu * Vol    # Masa (kg)

# Aire a condiciones locales (UDLAP)
nu_aire = 1.7e-5    # Viscosidad cinemática (m^2/s) corregida
k_aire = 0.026      # Conductividad térmica (W/m·K)
Pr = 0.707          # Número de Prandtl

# --- 2. Cálculo de h (Predicción) ---
V = 20.64           # ¡Velocidad experimental real corregida!
Re = (V * D) / nu_aire

# Correlación de Churchill-Bernstein CORREGIDA (Exponentes 5/8 y 4/5)
Nu = 0.3 + ((0.62 * Re^0.5 * Pr^(1/3)) / (1 + (0.4/Pr)^(2/3))^0.25) * (1 + (Re/282000)^(5/8))^(4/5)
h = (Nu * k_aire) / D

# --- 3. Simulación del Enfriamiento ---
Ti = 80.0           # Temperatura inicial (°C)
T_inf = 24.5        # Temperatura ambiente (°C)
t = 0:1:150         # Tiempo de simulación (s)

# Solución analítica del modelo de capacitancia global
tau = (m * cp_cu) / (h * As)  
T_t = T_inf .+ (Ti - T_inf) .* exp.(-t ./ tau)

# --- 4. Gráfica de Predicción ---
p_enfriamiento = plot(
    xlabel="Tiempo t (s)", 
    ylabel="Temperatura T (°C)",
    size=(1600, 800),       # Proporción 2:1 es el estándar para revistas
    dpi=600,
    xticks=0:10:150,        # Pasos reales de 25 s
    yticks=20:5:80,        # Pasos reales de 10 °C
    legend=:topright,
    framestyle=:box         # Añade un recuadro cerrado muy elegante
)

# 1ro: Dibujamos la asíntota térmica de fondo (T ambiente)
hline!(p_enfriamiento, [T_inf], 
       label="T. Ambiente (24.5 °C)", 
       color=:gray, linestyle=:dash, lw=2.0)

# 2do: Dibujamos la curva de enfriamiento encima
plot!(p_enfriamiento, t, T_t, 
      color=:darkorange,
      label="Capacitancia Global (h = $(round(h, digits=2)) W/m^2K)")

# Mostrar y guardar
display(p_enfriamiento)
savefig(p_enfriamiento, joinpath(@__DIR__, "prediccion_enfriamiento.pdf"))

println("Simulación terminada. Coeficiente h predicho: $h W/m²K")