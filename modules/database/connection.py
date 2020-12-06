from sqlalchemy import create_engine


def connect(dbpath):
  engine = create_engine('sqlite:///{}'.format(dbpath), echo=True)
  return engine

def create_schema(engine):
  # nothing
  pass