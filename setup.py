########
# Script for setting up and creating database, other requirements
########

import os
from datetime import datetime
import models.twitter as twm
from models.twitter import BatchQueue
import modules.config.config as cnf
import modules.database.connection as conn
from sqlalchemy.orm import Session

print('sqlite:///{}'.format(cnf._DB_PATH_))

engine = conn.connect(cnf._DB_PATH_)

twm.setup(engine)

## Load crappy ben shapiro
used_keys = {}
queue_item = BatchQueue(type = "follower_account")
with Session(engine) as session:
  for filename in [os.sep.join([cnf._DATA_PATH_, 'BenShapiro.follwers.txt']), os.sep.join([cnf._DATA_PATH_, 'BenShapiro.follwers.orig.txt'])]:
    file = open(filename)
    for line in file:
      twitter_id = int(line)
      if twitter_id not in used_keys:
        queue_item.date_added = datetime.now()
        queue_item.remote_id = int(line)
        used_keys[twitter_id] = True
        session.merge(queue_item)
  del used_keys
  session.commit()
