# Caracterización Hidrodinámica y Termo-Fluidodinámica en Bancos de Cilindros

Este repositorio contiene los datos experimentales y los scripts de análisis computacional utilizados en el artículo científico: **"Caracterización Hidrodinámica y Termo-Fluidodinámica mediante Estudio Numérico-Experimental de Flujo Cruzado en Bancos de Cilindros"**.

El proyecto implementa una metodología híbrida que acopla la metrología física obtenida de un túnel de viento de circuito abierto (TE93 de TecQuipment) con técnicas de análisis numérico en Julia. Esto permite extender la resolución de los datos analógicos para visualizar matemáticamente la estructura bidimensional del campo de velocidades y predecir respuestas termodinámicas transitorias.

## 📦 Requisitos y Dependencias

El código fue desarrollado y probado en **Julia (v1.12)**. Para ejecutar los scripts, es necesario instalar los siguientes paquetes en el entorno local de Julia:

```julia
using Pkg
Pkg.add(["CSV", "DataFrames", "LsqFit", "Plots", "Interpolations", "Trapz", "Measures"])
