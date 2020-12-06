import pathlib, os
# from pySRE import pySRE

# pySRE = pySRE.PySRC()
# print("\nCurrrent engine: %s\n" % pySRE.execjs_engine)

# use workin direcory for now
_APP_PATH_ = str(pathlib.Path().absolute())
# app directory/data
_DATA_PATH_ = os.sep.join([_APP_PATH_, 'data'])

# app directory/data/twitter.sqlite
_DB_PATH_ = os.sep.join([_DATA_PATH_, 'twitter.sqlite'])
