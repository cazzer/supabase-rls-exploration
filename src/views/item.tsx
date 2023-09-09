import React, { useMemo, useRef } from 'react'
import { useDelete, useUpdate } from 'react-supabase'
import { Rect } from 'react-konva'
import { Easings } from 'konva/lib/Tween'
import { KonvaEventObject } from 'konva/lib/Node'

export default function Item({ item }: { item: any }) {
  const rect = useRef(null)
  const [updateItemResult, updateItem] = useUpdate('items')
  const [deleteResult, deleteItem] = useDelete('items')

  if (updateItemResult.error != null) {
    console.error('Update error:', updateItemResult.error)
  }

  if (deleteResult.error != null) {
    console.error('Delete error:', deleteResult.error)
  }

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
      (query: any) => query.eq('id', item.id)
    )
  }

  const handleClick = (event: KonvaEventObject<MouseEvent>): void => {
    event.cancelBubble = true

    if (event.evt.shiftKey) {
      updateItem(
        {
          public: !item.public,
        },
        (query: any) => query.eq('id', item.id)
      )
    } else {
      deleteItem((query: any) => query.eq('id', item.id))
    }
  }

  const reactAttrs = getRectAttributes(item.metadata)

  return (
    <Rect
      ref={rect}
      width={reactAttrs.width}
      height={reactAttrs.height}
      x={reactAttrs.x}
      y={reactAttrs.y}
      stroke={item.public ? 'green' : 'black'}
      strokeEnabled={item.public}
      fill={`#${item.metadata?.color || 'black'}`}
      shadowBlur={5}
      onDragEnd={handleDragEnd}
      onClick={handleClick}
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
