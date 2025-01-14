import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Route, Routes } from 'react-router-dom'

import { Layout } from './components/Layout'
import { path } from './constants/path'
import { NotFound } from './pages/Errors'
import { Show as DefinitionList } from './pages/DefinitionList'
import { Index as LicenseIndex } from './pages/Lincense'
import { Index as ModuleIndex, Show as ModuleShow } from './pages/Modules'
import { Index as SourceIndex, Show as SourceShow } from './pages/Sources'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout isLoading={false} />}>
          <Route path={path.home()} element={<DefinitionList />} />
          <Route path={path.sources.index()} element={<SourceIndex />} />
          <Route path={path.sources.show(':sourceName')} element={<SourceShow />} />
          <Route path={path.modules.index()} element={<ModuleIndex />} />
          <Route path={path.modules.show(['*'])} element={<ModuleShow />} />
          <Route path={path.licenses.index()} element={<LicenseIndex />} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
    </BrowserRouter>
  </React.StrictMode>,
)
