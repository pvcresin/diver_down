import { idsToBitId } from '@/utils/bitId'

export const path = {
  home: () => '/',
  definitions: {
    show: (bitId: string) => `/definitions/${bitId}`,
  },
  sources: {
    index: () => '/sources',
    show: (sourceName: string) => `/sources/${sourceName}`,
  },
  modules: {
    index: () => '/modules',
    show: (moduleNames: string[]) => `/modules/${moduleNames.join('/')}`,
  },
  licenses: {
    index: () => '/licenses',
  },
  api: {
    pid: () => `/api/pid.json`,
    initializationStatus: () => `/api/initialization_status.json`,
    definitions: {
      index: () => '/api/definitions.json',
      show: (ids: number[]) => `/api/definitions/${idsToBitId(ids)}.json`,
    },
    sources: {
      index: () => '/api/sources.json',
      show: (sourceName: string) => `/api/sources/${sourceName}.json`,
      memo: {
        update: (sourceName: string) => `/api/sources/${sourceName}/memo.json`,
      },
      modules: {
        update: (sourceName: string) => `/api/sources/${sourceName}/modules.json`,
      },
    },
    modules: {
      index: () => '/api/modules.json',
      show: (moduleNames: string[]) => `/api/modules/${moduleNames.join('/')}.json`,
    },
  },
}
