require('dotenv').config({ path: '~/wiggly/wiggly-nest/.env' });
const jwt = require("jsonwebtoken");

// 프로그램에서 사용하는 camelCase을 DB에서 사용하는 snake_case로 변수명 혹은 값 수정
function camelToSnake(object) {
    return converter(object,
        (it)=>it.replace(/([A-Z])/g, "_$1").toLowerCase())
}

// DB에서 사용하는 snake_case을 프로그램에서 사용하는 camelCase로 수정
function snakeToCamel(object) {
    return converter(object,
        (it)=>it.replace(/(_\w)/g, m => m[1].toUpperCase()))
}

// 수정할 데이터의 값에 따라 다르게 수정
const converter = (object, convert) =>
    // 배열이면 배열을 수정하는 로직
    Array.isArray(object) ? convertArray(object, convert):
    // 객체면 객체를 수정하는 로직
    typeof object === 'object' ? convertObject(object, convert):
    // 일반 문자열이면 수정하는 로직
    typeof object === 'string' ? convert(object):
    // 숫자, bool 등의 값이면 수정하지 않음
    object

// 배열의 요소 하나하나를 객체로 쪼개어 수정 후 합쳐 반환하는 로직
const convertArray = (array, convert) =>
    array.map(obj => convertObject(obj, convert));

// 객체의 키값을 수정해 새로운 객체의 키값으로 설정하는 로직
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

// jwt에서 서버에서 정한 값을 불러오는 로직
const verify = async (token) =>
    jwt.verify(token, process.env.ACCESS_SECRET);

// 자주 쓰일 jwt 오류 검출기
const UnAuthorized = (res) => res.status(401).json({
    message: 'Unauthorized',
    reason: 'Insufficient permissions to access this resource.'})

// 객체에 id값이 포함 됐는지 확인하는 로직
const noId = (object) => {
    // 만약 객체가 비었거나 null값이거나, 객체가 아니면 검사에 오류가 나므로 미리 확인
    if (typeof object !== 'object' || object === null) return false
    return !object.hasOwnProperty('id')
}

// req의 path는 /를 가진 채 반환되어, 실제 입력값 가져오는 로직
const getPath = (req) =>req.path.slice(1)

module.exports = {camelToSnake, snakeToCamel, verify, UnAuthorized, noId, getPath}