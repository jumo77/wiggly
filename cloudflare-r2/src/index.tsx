import { Hono } from 'hono'

// 사용하는 R2 Bucket으로 객체 세팅
type Bindings = {
  WIGGLY: R2Bucket
}

// Hono에게 R2 Bucket을 inject
const app = new Hono<{ Bindings: Bindings }>()

// 잘못된 주소에 대한 응답
app.notFound((c)=>(
    c.text('Wrong Url', 404)
))

// 미디어 불러오기
app.get('/:key', async (c)=>{
    const key = c.req.param('key');

    // R2에서 파일 불러오기
    const image = await c.env.WIGGLY.get(key)
    // R2에서 불러온 이미지 파일이 없을 때
    if (!image) {
        return c.text('Not Found', 404);
    }

    // 불러온 파일에서 내용 추출
    const buffer = await image.arrayBuffer()
    // 불러온 파일에 내용이 없을 때
    if (!buffer) {
        return c.text('Content Not Found', 404);
    }

    // 불러온 파일 포멧 확인
    const ext = image.key.split('.').pop()
    // 불러온 이미지에 포멧이 명시되지 않았을 때
    if (!ext) {
        return c.text('Content Not Found', 404);
    }

    // 이미지 포멧 리스트
    const mimeTypes = {
        jpg: 'image/jpeg',
        jpeg: ' image/jpeg',
        png: 'image/png',
        gif: 'image/gif',
        svg: 'image/svg+xml',
    }

    // 파일의 포멧까지 전송
    return c.body(buffer, {headers: {
            "Content-Type":
                mimeTypes[ext as keyof typeof mimeTypes]
                // 파일의 포멧이 위에 명시되지 않았을 때
                || 'application/octet-stream'
    }})
})
// 파일 업로드
app.post('/file/upload', async (c)=> {
    // 요청의 body 가져오기
    const body = await c.req.parseBody();
    // body에 담긴 파일 가져오기
    const file = body['file'];
    // 파일이 없거나 파일이 아닐 때
    if (!file || !(file instanceof File)) return c.json({result: 'file not found'},
        404);

    // 파일 저장
    const fileName = new Date() + file.name;
    const r2 = await c.env.WIGGLY.put(fileName, file)
    // 파일 저장에 실패했을 때
    if (!r2) return c.json({result: 'failed to put in R2 Storage'}, 404);

    // 파일 저장에 성공했을 때 저장된 이름 반환
    return c.json({result: fileName}, 201);
})
export default app
