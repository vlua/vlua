require("runtime-core/src/scheduler")

describe('scheduler', function()
  it('nextTick', function()
    local calls = {}
    local dummyThen = Promise:resolve():tsvar_then()
    local job1 = function()
      table.insert(calls, 'job1')
    end
    
    local job2 = function()
      table.insert(calls, 'job2')
    end
    
    nextTick(job1)
    job2()
    expect(#calls):toBe(1)
    expect(#calls):toBe(2)
    expect(calls):toMatchObject({'job2', 'job1'})
  end
  )
  describe('queueJob', function()
    it('basic usage', function()
      local calls = {}
      local job1 = function()
        table.insert(calls, 'job1')
      end
      
      local job2 = function()
        table.insert(calls, 'job2')
      end
      
      queueJob(job1)
      queueJob(job2)
      expect(calls):toEqual({})
      expect(calls):toEqual({'job1', 'job2'})
    end
    )
    it('should dedupe queued jobs', function()
      local calls = {}
      local job1 = function()
        table.insert(calls, 'job1')
      end
      
      local job2 = function()
        table.insert(calls, 'job2')
      end
      
      queueJob(job1)
      queueJob(job2)
      queueJob(job1)
      queueJob(job2)
      expect(calls):toEqual({})
      expect(calls):toEqual({'job1', 'job2'})
    end
    )
    it('queueJob while flushing', function()
      local calls = {}
      local job1 = function()
        table.insert(calls, 'job1')
        queueJob(job2)
      end
      
      local job2 = function()
        table.insert(calls, 'job2')
      end
      
      queueJob(job1)
      expect(calls):toEqual({'job1', 'job2'})
    end
    )
  end
  )
  describe('queuePostFlushCb', function()
    it('basic usage', function()
      local calls = {}
      local cb1 = function()
        table.insert(calls, 'cb1')
      end
      
      local cb2 = function()
        table.insert(calls, 'cb2')
      end
      
      local cb3 = function()
        table.insert(calls, 'cb3')
      end
      
      queuePostFlushCb({cb1, cb2})
      queuePostFlushCb(cb3)
      expect(calls):toEqual({})
      expect(calls):toEqual({'cb1', 'cb2', 'cb3'})
    end
    )
    it('should dedupe queued postFlushCb', function()
      local calls = {}
      local cb1 = function()
        table.insert(calls, 'cb1')
      end
      
      local cb2 = function()
        table.insert(calls, 'cb2')
      end
      
      local cb3 = function()
        table.insert(calls, 'cb3')
      end
      
      queuePostFlushCb({cb1, cb2})
      queuePostFlushCb(cb3)
      queuePostFlushCb({cb1, cb3})
      queuePostFlushCb(cb2)
      expect(calls):toEqual({})
      expect(calls):toEqual({'cb1', 'cb2', 'cb3'})
    end
    )
    it('queuePostFlushCb while flushing', function()
      local calls = {}
      local cb1 = function()
        table.insert(calls, 'cb1')
        queuePostFlushCb(cb2)
      end
      
      local cb2 = function()
        table.insert(calls, 'cb2')
      end
      
      queuePostFlushCb(cb1)
      expect(calls):toEqual({'cb1', 'cb2'})
    end
    )
  end
  )
  describe('queueJob w/ queuePostFlushCb', function()
    it('queueJob inside postFlushCb', function()
      local calls = {}
      local job1 = function()
        table.insert(calls, 'job1')
      end
      
      local cb1 = function()
        table.insert(calls, 'cb1')
        queueJob(job1)
      end
      
      queuePostFlushCb(cb1)
      expect(calls):toEqual({'cb1', 'job1'})
    end
    )
    it('queueJob & postFlushCb inside postFlushCb', function()
      local calls = {}
      local job1 = function()
        table.insert(calls, 'job1')
      end
      
      local cb1 = function()
        table.insert(calls, 'cb1')
        queuePostFlushCb(cb2)
        queueJob(job1)
      end
      
      local cb2 = function()
        table.insert(calls, 'cb2')
      end
      
      queuePostFlushCb(cb1)
      expect(calls):toEqual({'cb1', 'job1', 'cb2'})
    end
    )
    it('postFlushCb inside queueJob', function()
      local calls = {}
      local job1 = function()
        table.insert(calls, 'job1')
        queuePostFlushCb(cb1)
      end
      
      local cb1 = function()
        table.insert(calls, 'cb1')
      end
      
      queueJob(job1)
      expect(calls):toEqual({'job1', 'cb1'})
    end
    )
    it('queueJob & postFlushCb inside queueJob', function()
      local calls = {}
      local job1 = function()
        table.insert(calls, 'job1')
        queuePostFlushCb(cb1)
        queueJob(job2)
      end
      
      local job2 = function()
        table.insert(calls, 'job2')
      end
      
      local cb1 = function()
        table.insert(calls, 'cb1')
      end
      
      queueJob(job1)
      expect(calls):toEqual({'job1', 'job2', 'cb1'})
    end
    )
    it('nested queueJob w/ postFlushCb', function()
      local calls = {}
      local job1 = function()
        table.insert(calls, 'job1')
        queuePostFlushCb(cb1)
        queueJob(job2)
      end
      
      local job2 = function()
        table.insert(calls, 'job2')
        queuePostFlushCb(cb2)
      end
      
      local cb1 = function()
        table.insert(calls, 'cb1')
      end
      
      local cb2 = function()
        table.insert(calls, 'cb2')
      end
      
      queueJob(job1)
      expect(calls):toEqual({'job1', 'job2', 'cb1', 'cb2'})
    end
    )
  end
  )
  test('invalidateJob', function()
    local calls = {}
    local job1 = function()
      table.insert(calls, 'job1')
      invalidateJob(job2)
      job2()
    end
    
    local job2 = function()
      table.insert(calls, 'job2')
    end
    
    local job3 = function()
      table.insert(calls, 'job3')
    end
    
    local job4 = function()
      table.insert(calls, 'job4')
    end
    
    queueJob(job1)
    queueJob(job2)
    queueJob(job3)
    queuePostFlushCb(job4)
    expect(calls):toEqual({})
    expect(calls):toEqual({'job1', 'job2', 'job3', 'job4'})
  end
  )
  test('sort job based on id', function()
    local calls = {}
    local job1 = function()
      table.insert(calls, 'job1')
    end
    
    local job2 = function()
      table.insert(calls, 'job2')
    end
    
    job2.id = 2
    local job3 = function()
      table.insert(calls, 'job3')
    end
    
    job3.id = 1
    queueJob(job1)
    queueJob(job2)
    queueJob(job3)
    expect(calls):toEqual({'job3', 'job2', 'job1'})
  end
  )
end
)