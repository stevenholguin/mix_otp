defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup  do
    bucket = start_supervised!(KV.Bucket)
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    # {:ok, bucket} = KV.Bucket.start_link([])
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3

    KV.Bucket.put(bucket, "hello", "world")
    assert KV.Bucket.delete(bucket, "hello") == "world"

  end
end
