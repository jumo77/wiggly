export const camelToSnake = (object) => {
    return converter(object,
        (it)=>it.replace(/([A-Z])/g, "_$1").toLowerCase())
}

export const snakeToCamel= (object) => {
    return converter(object,
        (it)=>it.replace(/(_\w)/g, m => m[1].toUpperCase()))
}

export const converter = (object, convert) =>
    Array.isArray(object) ? convertArray(object, convert):
        typeof object === 'object' ? convertObject(object, convert):
            typeof object === 'string' ? convert(object):
                object

const convertArray = (array, convert) =>
    array.map(obj => convertObject(obj, convert));

const convertObject = (object, convert) => {
    const newObject = {};
    for (const key in object) {
        if (object.hasOwnProperty(key)){
            const camelKey = convert(key)
            newObject[camelKey] = object[key]
        }
    }
    return newObject
}
