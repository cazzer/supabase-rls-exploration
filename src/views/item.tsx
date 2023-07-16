import React, { useMemo, useRef, useState } from 'react'
import { useDelete, useUpdate } from 'react-supabase'
import { Rect } from 'react-konva'
import { Easings } from 'konva/lib/Tween'
import { KonvaEventObject } from 'konva/lib/Node'

export default function Item({ item }: { item: any }) {
  const rect = useRef(null)
  const [stateSettings, setStateSettings] = useState({
    editing: false,
    local: false,
  })
  const [itemState, setItemState] = useState({ ...item })
  const [_, updateItem] = useUpdate('items')
  const [deleteResult, deleteItem] = useDelete('items')

  useMemo(() => {
    if (!rect.current) {
      return
    }

    // @ts-expect-error
    rect.current.to({
      ...getRectAttributes(item.metadata),
      duration: 0.1,
      easing: Easings.StrongEaseIn,
    })
  }, [item])

  const handleDragEnd = (event: any) => {
    updateItem(
      {
        metadata: {
          ...item.metadata,
          x: event.target.attrs.x,
          y: event.target.attrs.y,
        },
      },
      (query) => query.eq('id', item.id)
    )
  }

  const handleDeleteClick = (event: KonvaEventObject<MouseEvent>): void => {
    event.cancelBubble = true
    deleteItem((query) => query.eq('id', item.id))
  }

  const itemToUse = stateSettings.local ? itemState : item
  const reactAttrs = getRectAttributes(itemToUse.metadata)

  return (
    <Rect
      width={reactAttrs.width}
      height={reactAttrs.height}
      x={reactAttrs.x}
      y={reactAttrs.y}
      stroke="black"
      strokeWidth={2}
      strokeEnabled={itemToUse.metadata?.editing || false}
      fill={`#${itemToUse.metadata?.color || 'black'}`}
      shadowBlur={5}
      onDragEnd={handleDragEnd}
      onClick={handleDeleteClick}
      draggable
    />
  )
}

function getRectAttributes(metadata: any) {
  return {
    x: metadata?.x || 0,
    y: metadata?.y || 0,
    width: metadata?.width || 100,
    height: metadata?.height || 100,
  }
}
