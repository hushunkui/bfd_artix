## Каталоги и файлы
* `./prj_create.bat` - сценарий создания (update) проекта Xilinx Vivado
* `./prj_gold_create.bat` - сценарий создания (golden) проекта Xilinx Vivado
* `./src` - исходники проекта FPGA
    * `fpga_reg.h` - регистры FPGA
* `./firmware`
    * `*.bit` - Binary configuration data file containing header information that does not need to be downloaded to the FPGA
    * `*.bin` - Binary configuration data file with no header information.
* `./sim` - моделирование
* `./jtag_download.bat` - сценарий загрузки прошивки через JTAG
* `./flash_download.bat` - сценарий загрузки прошивки в SPI flash
* `./flash_file_generate.bat` - сценарий конвертирования прошивки FPGA (BIT файл) в файл для загрузки в SPI flash

## Создание проекта Xilinx Vivado
* Скорректировать переменные среды Windows:
    * Открыть окно "Система" - На клавиатуре последовательно нажать `Win` и `Pause`
    * Вызвать следующие диалоги: Система > Дополнительные параметры системы > Переменные среды
    * Создать переменную окружения
        * В поле имя переменной задаем - `XILINX_VV`
        * В поле значение переменной добавляем путь к каталогу куда установлен Xilinx Vivado 2018.2. `(c:\Xilinx\Vivado\2018.2\)`
    * Создать переменную окружения
        * В поле имя переменной задаем - `XILINX_SDK`
        * В поле значение переменной добавляем путь к каталогу куда установлен Xilinx SDK 2018.2. `(c:\Xilinx\SDK\2018.2\)`
* Запустить сценарий **`./prj_create.bat`**

## Моделирование

## Boot FPGA
Qspi flash содержит 2-е прошивки FPGA:

* golden - аварийная прошивка
* update - рабочая прошивка

В случае если по каким либо причинам не возможно загрузить UPDATE прошивку, загружается GOLDEN прошивка.
GOLDEN прошивка обеспечивает доступ к FPGA QSPI FLASH для того чтобы можно было обновить поврежденную UPDATE прошивку.
Кроме того в UPDATE и GOLDEN прошивках есть пользователький SPI через который модуль ZYNQ может узнать тип загруженной прошивки UPDATE/GOLDEN


## Полезные орции Xilinx Vivado
* `pwd`
* `cd d:/Work/xxx/BFD/artix`
* `write_bd_tcl -force -no_ip_version ./prj_create.tcl`
* `set_param general.maxThreads 8`
* `set_property {STEPS.PLACE_DESIGN.ARGS.MORE OPTIONS} {set_param general.maxThreads 8} [get_runs impl_1]`
