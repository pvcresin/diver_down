import React, { FC, useCallback, useContext, useMemo, useState } from 'react'
import { ComboBoxItem } from 'smarthr-ui/lib/components/ComboBox/types'

import { Button, Cluster, FaXmarkIcon, FormControl, Input, SingleComboBox, Text } from '@/components/ui'
import { Module } from '@/models/module'
import { useModules } from '@/repositories/moduleRepository'
import { useSourceModules } from '@/repositories/sourceModulesRepository'
import { RecentModulesContext } from '@/context/RecentModulesContext'

type Item = ComboBoxItem<Module[]>

type Props = {
  sourceName: string
  initialModules: Module[]
  onClose: () => void
  onUpdate: () => void
}

const equalModules = (a: Module[], b: Module[]) => a.every((module, index) => module.moduleName === (b[index]?.moduleName ?? ''))

const convertModulesToItem = (modules: Module[]): Item => ({
  label: modules.map((module) => module.moduleName).join(' / '),
  value: modules.map((module) => module.moduleName).join('/'),
  data: modules,
})

const DELIMITER_RE = /\s*\/\s*/

export const SourceModulesComboBox: FC<Props> = ({ sourceName, initialModules, onClose, onUpdate }) => {
  const { setRecentModules } = useContext(RecentModulesContext)
  const { data, isLoading, mutate } = useModules()
  const { trigger } = useSourceModules(sourceName)
  const defaultItems: Item[] = useMemo(() => (data ?? []).map((modules) => convertModulesToItem(modules)), [data])

  const [temporaryItem, setTemporaryItem] = useState<Item | null>(null)
  const [selectedItem, setSelectedItem] = useState<Item | null>(
    defaultItems.find((item) => equalModules(item.data!, initialModules)) ?? null,
  )

  const handleSelectItem = useCallback(
    (item: Item) => {
      setSelectedItem(item)

      if (item !== temporaryItem) {
        setTemporaryItem(null)
      }
    },
    [setSelectedItem, temporaryItem, setTemporaryItem],
  )

  const handleClear = useCallback(() => {
    setSelectedItem(null)
  }, [setSelectedItem])

  const handleAddItem = useCallback(
    (label: string) => {
      const temporaryModules: Module[] = label.split(DELIMITER_RE).map((moduleName) => ({ moduleName }))
      const newItem = convertModulesToItem(temporaryModules)

      setTemporaryItem(newItem)
      setSelectedItem(newItem)
    },
    [setTemporaryItem, setSelectedItem],
  )

  const handleUpdate = useCallback(async () => {
    const modules = selectedItem?.data ?? []
    await trigger({ modules })
    setRecentModules(modules)
    mutate()
    onUpdate()
  }, [mutate, trigger, selectedItem, onUpdate])

  const items = useMemo(() => {
    const array = [...defaultItems]

    if (temporaryItem) {
      array.push(temporaryItem)
    }

    return array
  }, [defaultItems, temporaryItem])

  return (
    <Cluster>
      <div>
        <FormControl title="Modules" helpMessage="Submodules are separated by slash">
          <SingleComboBox
            items={items}
            selectedItem={selectedItem}
            dropdownHelpMessage="Select or input Module"
            creatable
            isLoading={isLoading}
            onSelect={handleSelectItem}
            onClear={handleClear}
            onAdd={handleAddItem}
            width="200px"
            decorators={{
              noResultText: () => `no result.`,
              destroyButtonIconAlt: (text) => `destroy.(${text})`,
            }}
          />
        </FormControl>
      </div>
      <Button square={true} variant="primary" onClick={handleUpdate} size="s">
        Update
      </Button>
      <Button square={true} onClick={onClose} size="s">
        <FaXmarkIcon alt="Cancel" />
      </Button>
    </Cluster>
  )
}
