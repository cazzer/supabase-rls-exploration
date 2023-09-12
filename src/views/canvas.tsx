import React from 'react'
import { useInsert, useRealtime } from 'react-supabase'
import { Stage, Layer } from 'react-konva'

import Item from './item'
import { useAuth } from '../auth/hook'

export default function CanvasView() {
  const [result, _] = useRealtime('items')
  const [insertResult, insertItem] = useInsert('items')
  const { user } = useAuth()

  const { data, fetching, error } = result

  if (fetching) return <p>Loading...</p>
  if (error != null || data == null) return <p>Oh no... {error?.message}</p>

  const handleStageClick = (event: any) => {
    insertItem({
      metadata: {
        x: event.evt.layerX - 50,
        y: event.evt.layerY - 50,
        width: 100,
        height: 100,
        color: user.id.substr(0, 6),
      },
    })
  }

  return (
    <Stage
      width={window.innerWidth}
      height={window.innerHeight}
      onClick={handleStageClick}
    >
      <Layer>
        {data.map((item: any) => (
          <Item key={item.id} item={item} />
        ))}
      </Layer>
    </Stage>
  )
}
