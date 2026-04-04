
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

<!-- badges: end -->

# Riesgo de la transmisión de dengue en el área no endémica de México

## Objetivo

El objetivo del presente documento es presentar los detalles
metodológicos, técnicos y el flujo de trabajo para predecir las
probabilidades de la presencia de la transmisión del dengue en el área
no endémica de México usando algoritmos de Machine Learning,
específicamente XGBoost
(<https://xgboost.readthedocs.io/en/release_3.2.0/>) y LightGBM
(<https://lightgbm.readthedocs.io/en/latest/>).

**Arboles de decision, Bagging (Random Forest) y Boosting (LightGBM y
XGBoost)**. Un árbol de decisión (DT) extrae los patrones y las
tendencias de los datos aprendiendo con la división de las variables en
la base de datos de forma recursiva eligiendo una variable y un valor
para separar dos conjuntos mutuamente exclusivos de acuerdo con una
métrica (Gini, entropía, ect) y repite el proceso hasta un criterio de
parada. La fortaleza de los árboles de decisión es que son simples y muy
intuitivos de comprender y sus debilidades incluyen el sobreajuste
(memorizan las características individuales y el ruido con facilidad si
no se controla el número de observaciones en casa hoja) y la misma
variable puede aparecer en varias ramas. El bagging es la contracción
del Bootstrap Aggregating es cual es muestreo con remplazo y Random
Forest es un bagging de muchos arboles de decisión generados muestreando
la base de datos, adicionalmente cada árbol incluye un subconjunto de
variables rompiendo la colinealidad entre variables y al final cada
árbol formado independientemente y de forma paralela, vota dando como
resultado final un promedio de los votos. El boosting al contrario del
bagging (arboles independientes y paralelos), los árboles son
construidos de manera secuencial donde cada árbol aprende de los errores
del árbol previo integrando el error dentro del modelo. XGBoost
(<https://xgboost.readthedocs.io/en/release_3.2.0/>) fue creado el 2016
por DMLC y los árboles ajustan los residuos a través de minimizar la
función de pérdida usando expansión de Taylor de segundo orden
(cuadrática) y a través de incorporar regularizaciones L1 (Lasso) y L2
(Ridge). LightGBM (<https://lightgbm.readthedocs.io/en/stable/>) fue
creado por Microsoft en el 2017 para trabajar con datos masivos (GOSS) y
datos categóricos (EFB) construyendo arboles por hoja buscando mayor
ganancia (mayor precisión) sin restricción de nivel. Tanto XGBoost y
LightGBM son algoritmos de última generación para datos tabulares que
están en la parte alta del ranking de las competencias de Machine
Learning como Kaggle (<https://www.kaggle.com>),
M6(<https://forecasters.org/resources/time-series-data/>),
solafune(<https://solafune.com>), DrivenData
(<https://www.drivendata.org>) y ML Contest(<https://mlcontests.com>).

> \[!IMPORTANT\] XGBoost (Extreme Gradient Boosting) is an open-source,
> highly efficient, and scalable machine learning library that
> implements optimized gradient-boosted decision trees (GBDT). It is
> designed for speed and performance, providing parallel computing,
> regularization to prevent overfitting, and built-in handling of
> missing values. It is widely used for classification, regression, and
> ranking tasks.

> \[!IMPORTANT\] LightGBM (Light Gradient Boosting Machine) is a
> high-performance, distributed gradient boosting framework developed by
> Microsoft. It is designed for speed and efficiency on large-scale
> data, utilizing leaf-wise tree growth, histogram-based algorithms, and
> Gradient-based One-Side Sampling (GOSS) to achieve faster training and
> low memory usage compared to traditional algorithms.

## Material y Métodos.

Con la finalidad de predecir las probabilidades de la presencia de la
transmisión de dengue, se usaron como inputs a la variable objetivo
(target) y los features en ambos algoritmos de machine learning. Como
features o variables predictoras se usaron las variables bioclimáticas,
ambientales, antropogénicas y el target o variable objetivo fue definida
como la presencia de casos/ausencia de casos. El resultado (output)
esperado fueron los mapas de condiciones idóneas (hábitat suitability) o
mapas de probabilidad y los algoritmos fueron implementados para el área
no endémica de México en los últimos cuatro brotes epidémicos observados
en México (2008-2019, 2012-2013, 2018-2020, 2023-2025).

### Área de estudio.

El área no endémica a la transmisión de dengue en México comprende el
área geográfica que no ha sido invadida. Esta área está definida por los
municipios que no han sido invadidos por el dengue antes del 2020. Un
municipio es considerado invadido cuando su incidencia de casos
autóctonos de dengue de 1997 al 2019 supera los 2 casos por 100,000
habitantes (Harish et al 2024). El caso autóctono se define por su
identificación sin antecedente de viaje fuera de su zona de residencia
durante tres semanas o más prior a su etapa febril. El área no endémica
se distribuye entre las cadenas montañosas comprendidas por la Sierra
Madre Occidental (localizada frente el mar Pacífico en la región
occidental de la República Mexicana, orientada de noroeste a sureste y
extiende desde Sonora hasta Nayarit), la Sierra Madre Oriental
(localizada frente el Golfo de México, orientada de noroeste a sureste y
extiende desde Coahuila hasta Oaxaca) y delimitado por en el sur por el
eje Neovolcánico (localizada antes de la meseta central del país
recorriendo transversalmente el centro del país desde Veracruz hasta
Nayarit). El área endémica cubre una extensión de 799038 km2 (70
habitantes/km2 = 56469541/799038) donde viven aproximadamente el 45 % de
toda la población de México (n = 126014024 habitante) distribuidos en
1128 municipios (45 % (1228/2478) del total de municipios) y 66464
localidades (35% (66464/189432) del total de localidades). (incluir un
mapa interactivo donde se proporcione la zona endémica y no endémica).

### Datos epidemiológicos.

Con la finalidad de construir la base de datos de la variable objetivo
(target) se accedió a la base de datos de dengue del Módulo de
Enfermedades Transmitida por Vector (<https://vectores.sinave.gob.mx>)
del Sistema Nacional de Vigilancia Epidemiológica (SINAVE) de la
Dirección General de Epidemiología
(<https://www.gob.mx/salud/acciones-y-programas/direccion-general-de-epidemiologia>)
de la Secretaría de Salud Federal de México. La base de datos de dengue
incluye variables relacionadas con el diagnóstico clínico (probable,
confirmado, cuadro clínico) condición (importado, autóctono), pruebas de
laboratorio utilizadas (serología, PCR, serotipo, genotipo), datos
personales (edad, sexo, trabajo) y geográficos como la dirección del
domicilio del paciente (calle y número), colonia, localidad (nivel
administrativo 3), municipio (nivel administrativo 2) y estado (nivel
administrativo 1). La base de dengue fue agregada por localidad,
municipio, estado y generada para los últimos cuatro brotes epidémicos
(2008-2019, 2012-2013, 2018-2020, 2023-2025). Cada base (cuatro) fue
unida con la base de datos de las áreas geoestadísticas municipales
(AGEM) del marco geoestadístico (MG) y la base del identificador de
entidad territorial (ITER) del Instituto Nacional de Geografía y
Estadística (INEGI). Posteriormente, se extrajeron las localidades
positivas y se realizó un muestreo aleatorio con la finalidad de generar
pseudo-ausencias (background) sin sobrelape ambiental con los registros
de presencias dentro del área de interés a través de definir un buffer
equivalente a la distancia de la dependencia espacial y un tamaño de
muestra de n para las pseudo-ausencias.

#### Generación de los datos background.

Estudios previos han sugerido que el tamaño de muestra debe ser lo
suficientemente grande para muestrear exhaustivamente, y por lo tanto
representar toda la heterogeneidad del fenómeno biológico en del área de
estudio (Barbet-Massin, et al 2012, Valavi et al 2022). Para seleccionar
el tamaño de muestra óptimo donde las métricas de clasificación
converjan a un valor estable y el incremento no mejore la ganancia de
las métricas, se realizaron experimentos para evaluar diferentes tamaños
de muestra incrementales de 20 a 100000 (Valavi et al 2022). Los
experimentos fueron realizados con la base del 2023 al 2025 usando
LightGBM.

### Variables predictoras.

En la implementación los modelos predictivos se usaron variables
climáticas, ambientales y antropogénicas que han sido usadas previamente
como inputs en modelos predictivos de dengue y/o Ae. aegypti (Cattarino
et al 2020, Lim et al 2023, Lippi et al 2023, Lim et al 2025). Las
variables climáticas fueron obtenidas de WorldClim V1 Bioclim (Hijmans,
2005) a través Google Hearth Engine de Google. La base datos del bioclim
incluye una serie temporal de 1960 a 1991 y la resolución espacial
nativa es de 927.67 metros. La metodología para acceder a las bases fue
el siguiente. Primero se autenticó e inicializaron los servicios de
Google Hearth Engine a través de las credenciales del primer autor.
Segundo, se definió la imagen de la base de datos de WorldClim
(“WORLDCLIM/V1/BIO”). Tercero, se definió el área de interés (área no
endémica de México) y se extrajo su rectángulo geográfico (bounding
box). Cuarto, la imagen de google hearth engine downscaled a 100 metros
fue exportada y localmente alojado con extension tif. El mismo proceso
fue seguido para el resto de las variables climáticas (temperatura,
islas de calor y altitud), ambientales (ndvi, worldcover) y
antropogénicas (cover fraction) hospedadas en Google Hearth Engine.
Todas las capas se recortaron con los límites geográficos del área
endémica y se remuestrearon usando el método bilíneal tomando como
referencia una capa del Bioclim (Bio01) dowscaled a 100 m con la
finalidad de ajustar el extent geográfico y poder apilar todas las capas
en un mismo archivo geográfico el mismo CRS (Coordinate Reference
System) bajo el código EPSG 4326 (EPSG:4326). La capa raster del indice
de accesibilidad fue construido con modelo geoestadístico con INLA y
proyectado en los centroides de un templado de una capa raster (Bio01).
Posteriormente fue convertido a raster y guardado con extension tif.

#### Tabla de las variables climáticas, ambientales y antropogénicas

| Variable | Categoria | Código |
|----|:--:|:--:|
| Temperatura media anual | Climática | Bio1 |
| Rango medio diurno (Media mensual (temperatura máxima - temperatura mínima)) | Climática | Bio1 |
| Isotermalidad (BIO2/BIO7) (×100) | Climática | Bio3 |
| Estacionalidad de la temperatura (desviación estándar ×100) | Climática | Bio4 |
| Temperatura máxima del mes más cálido | Climática | Bio5 |
| Temperatura mínima del mes más frío | Climática | Bio6 |
| Rango anual de temperatura (BIO5-BIO6) | Climática | Bio7 |
| Temperatura media del trimestre más húmedo | Climática | Bio8 |
| Temperatura media del trimestre más seco | Climática | Bio9 |
| Temperatura media del trimestre más cálido | Climática | Bio10 |
| Temperatura media del trimestre más frío | Climática | Bio11 |
| Precipitación anual | Climática | Bio12 |
| Precipitación del mes más húmedo | Climática | Bio13 |
| Precipitación del mes más seco | Climática | Bio14 |
| Estacionalidad de la precipitación (coeficiente de variación) | Climática | Bio15 |
| Temperatura Media | Climática | Temperatura |
| Altitud | Climática | Altitud |
| NDVI | Ambiental | ndvi |
| Precipitación del trimestre más húmedo | Climática | Bio16 |
| Precipitación del trimestre más seco | Climática | Bio17 |
| Precipitación del trimestre más cálido | Climática | Bio18 |
| Precipitación del trimestre más frío | Climática | Bio19 |
| Porcentaje de cobertura de edificios | Antropogénica | urban |
| Pop | Antropogénica | pop |
| Indice de Accesibilidad | Antropogénica | ic |
| Huella Humana | Antropogénica | hfp |
| Índices humanos dinámicos | Antropogénica | dhi |
| Cobertura Vegetal | Ambiental | tree |

Tabla de las variables climáticas, ambientales y antropogénicas.

Las variables antropógenicas (Dinamyc Human Indices, Human Foot Print,
Population) fueron accesadas en los siguientes links.

| dataset | short name | reference | link |
|----|:---|---:|:--:|
| Dinamyc Human Indices | [dhi](https://silvis.forest.wisc.edu/data/DHIs-clusters/) | Coops et al 2018 | <https://silvis.forest.wisc.edu/data/DHIs-clusters/> |
| Human Foot Print | [hfp](hfp%20https://figshare.com/articles/figure/An_annual_global_terrestrial_Human_Footprint_dataset_from_2000_to_2018/16571064) | Mu et al 2022 | hfp <https://figshare.com/articles/figure/An_annual_global_terrestrial_Human_Footprint_dataset_from_2000_to_2018/16571064> |
| population | [pop](https://landscan.ornl.gov) | NA | <https://landscan.ornl.gov> |

Link de las variables antropógenicas

### Análisis

El flujo de trabajo para la implementación de los algoritmos de machine
learning para el análisis fue divido en cinco etapas (Train-Test
dataset, Preprocesamiento, Optimización de los hiperparámetros, modelo
final & análisis posteriores y predicción).

**Train-Test Dataset**. Las bases de datos fueron particionadas en una
base de datos para el adiestramiento de los algoritmos (train data) y
otra base para evaluar el rendimiento y sobreajuste del modelo (test
data) estratificando por la variable de dependiente (Presencia/Ausencia
o Presencia/Backgound). Con el train data se realizará el análisis
exploratorio bivariado y multivariado (EDA) con la finalidad de explorar
los valores perdidos, los valores extremos, identificar la correlación
de entre las variables predictoras (matriz de correlación y PCA),
calcular el porcentaje de registros, y la distribución de los valores
por los percentiles 25, 75, y 100 para cada variable.

**Preprocesamiento**. Una vez que se realice el EDA, se procedió a crear
la receta que básicamente consiste en la descripción de los pasos que
deben aplicarse a un conjunto de datos con el fin de prepararlo para el
análisis. En la receta incluyo instrucciones para codificar la fórmula
de la ecuación similar a como se ingresa la variable de respuesta y las
covariables en un lm o glm, la eliminación las variables con una
correlación mayor de 0.80 pearson (debido la existencia de correlación
entre las variables climáticas observadas en el eda multivariado), la
estandarización de las variables con media 0 y sd = 1, y finalmente se
balancearán los datos mediante el procesos de upsampling para alcanzar
una relación de 1:0.9 o mediante la importancia de la ponderación, para
el algoritmo LightGBM y XGBoost, respectivamente. El procesamiento lo
realiza automáticamente el software de manera interna tanto en el train
data como en el test data.

**Optimización de los hiperparámetros**. La optimización de los
hiperpárametros también conocido como el afinamiento y ajuste de los
hiperparámetros del algoritmo es el proceso mediante el cual se evalúan
uno o un conjunto de hiperparámetros de un rango de opciones con la
finalidad de mejorar el rendimiento de un modelo de machine learning
optimizando la métrica de evaluación (maximizando o minimizando) sin
provocar el sobreajuste del modelo (Owen, 2022). La optimización incluye
la definición del espacio de hiperparámetros, la selección de la
métrica, el esquema de remuestreo y la especificación del algoritmo. El
flujo de tranajo se usó remuestreo con validación cruzada con 10 fold y
dos repeticiones, las métricas de evaluación seleccionada fue
principalmente la sensibilidad (probabilidad de que modelo realice la
correcta predicción de las presencias de los casos), los algoritmos que
se implementarón fueron LightGBM y XGBoost, los hiperparámetros que se
afinaron fueron mtry, trees, tree_depth, loss_reduction, learn_rate y se
usó una malla de busqueda de 100 elementos para escanear los mejores
valores de los hiperparámetros. El rango de los valores de mtry será
acotado por la raíz cuadra del número de columnas (columnas 20, x = 4.4
igual a 5 redondeado) definiendo el valor mínimo como x-2 y el valor
máximo como x+2. Para encontrar la cantidad de árboles ideales en el
proceso de boosting se exploró un rango de 10 a 1000 árboles y la
profundidad del árbol fue establecido entre 2 a 7. En el resto de los
hiperparámetros, se confiará al algoritmo decidir el mejor valor. Modelo
Final. La evaluación del desempeño de los modelos finales para LightGBM
y XGBoost se realizó principalmente con la sensibilidad y los valores
superiores a 0.9 serán considerados aceptables para proyectar
espacialmente los valores predictivos en el área de estudio y para
extraer los valores de las variables más importantes. Así, mismo
diferencias menores a del 10% (0.1) en los valores de sensibilidad,
especificidad y accuracy en el train data versus el test data, serán
consideradas como evidencia de que no hay sobreajuste y que el modelo se
desempeña adecuadamente. Adicionalmente, se calculará la correlación
tetracorrica y el estadístico ROC parcial como una medida de
significancia estadística. EL ROC parcial reta la hipótesis nula “la
predicción de los modelos coinciden con los datos de adiestramiento con
mayor frecuencia que lo que se esperaría por asociación aleatoria de los
datos de presencias con la predicción en el área de estudio”.

**Análisis posteriores & predicción**. Los análisis posteriores a la
evaluación de los modelos finales, incluirá la gráfica de la importancia
de las variables como predictores de los modelos y la extracción y
proyección de los modelos obtenidos con LightGBM y XGBoost. Los modelos
serán proyectados como un mapa continuo en el área de estudio de la ZMCM
a una escala 100m y cada celda en el mapa representa la probabilidad de
que la celda tenga condiciones idóneas para la presencia del vector.
Mapa de riesgo. La concordancia espacial de las probabilidades entre los
diferentes brotes de dengue permite usar el sobrelape para construir los
estratos de riesgo en el área no endémica. Las probabilidades fueron
sujetos a un análisis de componentes principales y se extraerá un índice
definido como la combinación lineal de los componentes principales
individuales. Finalmente, con el índice se realizará un cluster análisis
para segmentarlo en cinco grupos de riesgo. Las categorías de riesgo
definidas serán Riesgo Muy Bajo, Riesgo Bajo, Riesgo Medio, Riesgo Alto,
y Riesgo Muy Alto.

**Dashboard**. Con los códigos se generará un dashboard que constará de
dos visualizaciones geográficas interactivas, la primera donde se
proporcionará el mapa de probabilidad de cada brote y la segunda se
proporcionará el mapa de riesgo del área no endémica. Los códigos se
subirán a GitHub y se enlazarán a Netlify. El proceso de conectar un
proyecto de análisis y visualización de ciencia de datos a GitHub y
Netlify es estándar y se realiza en seis pasos. En el primero se crea un
proyecto en R o Python inicializado con git, segundo paso se crea un
proyecto con el mismo nombre en GitHub, tercero se sincroniza ambos
proyectos, cuarto se generan todos los documentos y extensiones
necesarias para generar el html en la maquina local, quinto se
actualizan los archivos en GitHub (push), sexto se enlaza Netlify con
Github y el dashboard se despliega automáticamente. Con cada push local,
GitHub y Netlify actualizan el sitio web automáticamente.

## Referencias

Harish V, Colón-González FJ, Moreira FRR, Gibb R, Kraemer MUG, Davis M,
Reiner RC Jr, Pigott DM, Perkins TA, Weiss DJ, Bogoch II,
Vazquez-Prokopec G, Saide PM, Barbosa GL, Sabino EC, Khan K, Faria NR,
Hay SI, Correa-Morales F, Chiaravalloti-Neto F, Brady OJ. 2024. Human
movement and environmental barriers shape the emergence of dengue. Nat
Commun. 2024 May 28;15(1):4205. doi: 10.1038/s41467-024-48465-0.

Owen L. 2022. Hyperparameter Tuning with Python Boost your machine
learning model’s performance via hyperparameter tuning. Packt Publishing
Ltd Birmingham-Munbai. Barbet-Massin, et al 2012, Valavi et al 2022

Barbet-Massin M, Jiguet F, Helene-Albert C, Thuiller W. Selecting
pseudo-absences for species distribution models: how, where and how
many?. Methods in Ecology and Evolution, 3:327–338. doi:
10.1111/j.2041-210X.2011.00172.x

Valavi R, Guillera-Arroita G, Lahoz-Monfort JJ, Elith J. Predictive
performance of presence-only species distribution models: a benchmark
study with reproducible code. Ecological Monographs. 92(1): e01486
