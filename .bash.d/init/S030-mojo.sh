export MODULAR_HOME="${HOME}/.modular"
export PATH="${HOME}/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

# Mojo build needs MOJO_PYTHON_LIBRARY to be set to the path of the Python.
# https://github.com/modularml/mojo/issues/551
__find_python_for_mojo() {
  libpath="$(python3 -c 'import sysconfig; print(sysconfig.get_config_var("LIBDIR"))')"
  # shellcheck disable=2012
  pythonlib="$(ls "${libpath}"/libpython3.*.so "${libpath}"/libpython3.*.dylib 2>/dev/null | tail -n1)"
  export MOJO_PYTHON_LIBRARY="${libpath}/${pythonlib}"
}

__find_python_for_mojo
