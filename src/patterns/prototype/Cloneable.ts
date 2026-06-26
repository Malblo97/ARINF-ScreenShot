export interface Cloneable<T> {
  clone(): Promise<T>
}