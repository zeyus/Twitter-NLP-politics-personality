from sqlalchemy import (
    Column,
    String,
    Integer,
    Date,
    create_engine,
    DateTime,
    Boolean,
    ForeignKey,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, backref
from datetime import datetime

Base = declarative_base()

class BatchQueue(Base):
 
    __tablename__ = "BatchQueue"
 
    id = Column(Integer, primary_key=True)

    type = Column(String(40), index=True, nullable=False)
    remote_id = Column(Integer, index=True)
    saved_id = Column(Integer)
    parent_id = Column(Integer, index=True)
    date_added = Column(DateTime, nullable = False)
    date_accessed = Column(DateTime)
    date_added = Column(DateTime)
    
    completed = Column(Boolean, default = False)
 
    def __init__(self, type):
        self.type = type
        # self.remote_id = remote_id
        # self.date_added = date_added
        # self.saved_id = saved_id
        # self.date_accessed = date_accessed
        # self.completed = completed
        # self.parent_id = parent_id
 
    def __repr__(self):
        return (
            f"<BatchQueue {self.type}, {self.date_added}, " \
            f"{self.ParentTown}"
        )
 
 
def setup(engine):
    Base.metadata.create_all(engine)
 
 
