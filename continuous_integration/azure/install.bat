:: Install dependencies
if %USE_CONDA% == yes (
    :: The newly introduced changes to the Python packages in Anaconda
    :: are breaking our tests. Reverting to known working builds.
    if %PYTHON_VERSION% == 3.6 (
        conda install -q -y python=3.6.8=h9f7ef89_7
    )

    conda install -q -y -c spyder-ide --file requirements/conda.txt  --file requirements/pyls-pyall.txt
    if errorlevel 1 exit 1
    if %PYTHON_VERSION% == 2.7 (
        conda install -q -y -c spyder-ide --file requirements/pyls-py2.txt
    )



    conda install -q -y -c spyder-ide --file requirements/tests.txt
    if errorlevel 1 exit 1

    :: Github backend tests are failing with 1.1.1d
    conda install -q -y openssl>=1.1.1c
    if errorlevel 1 exit 1

    :: Remove spyder-kernels to be sure that we use its subrepo
    conda remove -q -y --force spyder-kernels
    if errorlevel 1 exit 1
) else (
    :: Github backend tests are failing with 1.1.1d
    conda install -q -y openssl>=1.1.1c
    if errorlevel 1 exit 1

    :: Install Spyder and its dependencies from our setup.py
    pip install -e .[test]
    if errorlevel 1 exit 1

    :: Install qtpy from Github
    pip install git+https://github.com/spyder-ide/qtpy.git
    if errorlevel 1 exit 1

    :: Install qtconsole from Github
    pip install git+https://github.com/jupyter/qtconsole.git
    if errorlevel 1 exit 1

    :: Remove spyder-kernels to be sure that we use its subrepo
    pip uninstall -q -y spyder-kernels
    if errorlevel 1 exit 1
)

:: To check our manifest
pip install check-manifest
if errorlevel 1 exit 1

:: Create environment for Jedi environments tests
conda create -n jedi-test-env -q -y python=3.6 flask spyder-kernels
if errorlevel 1 exit 1

conda list -n jedi-test-env
if errorlevel 1 exit 1

:: Create environment to test conda activation before launching a spyder kernel
conda create -n spytest-ž -q -y python=3.6 spyder-kernels
if errorlevel 1 exit 1

conda list -n spytest-ž
if errorlevel 1 exit 1

:: Install python-language-server from master
pip install -q --no-deps git+https://github.com/bnavigator/python-language-server@jedi-unpin
if errorlevel 1 exit 1

:: Install codecov
pip install -q codecov
if errorlevel 1 exit 1
